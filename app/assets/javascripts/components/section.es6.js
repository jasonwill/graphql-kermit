var React = require('react');
var Relay = require('react-relay');
var Comment = require('./comment.es6.js');
var classNames = require('classnames');
import CreateCommentMutation from '../mutations/comment/create_comment_mutation.es6.js';
import SectionVoteMutation from '../mutations/vote/section_vote_mutation.es6.js';
import SectionUnVoteMutation from '../mutations/vote/section_unvote_mutation.es6.js';
/*
  Component: Section
  Renders single section with author and comments
*/

class Section extends React.Component {

  constructor(props) {
   super(props);
   this._handleScrollLoad = this._handleScrollLoad.bind(this);
   this._handleCreate = this._handleCreate.bind(this);
   this._handleVote = this._handleVote.bind(this);
   this.state = { loading: false, done: false }
  }

  componentDidMount() {
    this._handleScrollLoad();
  }

  render() {
    var {section} = this.props;

    var voted = classNames({
      'fa fa-thumbs-up voted': this.props.section.voted,
      'fa fa-thumbs-o-up': !this.props.section.voted
    });

    return (
       <article>
         <div className='container'>
           <div className='row'>
             <div className='col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1'>
               <h2 className='section-heading'>
                { section.title }
                </h2>
                <div dangerouslySetInnerHTML={{__html: section.body }} />
               <div className="section-preview show">
                 <div className="section-meta">
                   <span className="author">
                     Taught by: //<em>{ section.user.name }</em>
                   </span>
                   <span className="date">
                    { LocalTime.relativeTimeAgo(new Date(section.created_at)) }
                   </span>
                   <span className="counters">
                     Comments: { section.comments_count }
                   </span>
                   <span className="counters">
                    <a onClick={this._handleVote}>
                      <span className={voted}></span>
                    </a>
                     { section.votes_count }
                   </span>
                 </div>
               </div>
             </div>
           </div>
         </div>

         <div className="comments-container">
          <div className='container'>
           <div className='row'>
             <div className='col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1'>
              <h1> Comments </h1>
              <textarea className="add-comment" onKeyDown={this._handleCreate} />
              {section.comments.edges.map(({node}) => (
                <Comment key={node.id} comment={node} root={section} />
              ))}
             </div>
             </div>
           </div>
           {this.state.loading ?  <div className="loadmore">
               <span className="fa fa-spin fa-spinner"></span>
             </div> : ''}
           {this.state.done ?  <div className="loadmore-done">
               <p>No more comments to load</p>
             </div> : ''}
         </div>

       </article>
    );
  }

  _handleVote(event) {
    if(App.loggedIn()) {
      if(this.props.section.voted) {
        Relay.Store.update(new SectionUnVoteMutation({section: this.props.section}))
      } else {
        Relay.Store.update(new SectionVoteMutation({section: this.props.section}))
      }
    } else {
      window.location.href = Routes.new_user_session_path();
    }
  }

  _handleCreate(event) {
    if(App.loggedIn()) {
      if(event.keyCode === 13 && event.target.value.length > 10) {
        Relay.Store.update(new CreateCommentMutation({section: this.props.section, body: event.target.value}))
        $('.add-comment').val('');
      }
    } else {
      window.location.href = Routes.new_user_session_path();
    }
  }

  _handleScrollLoad() {
    $(window).scroll(function() {
      if (App.scrolledToBottom() && !this.state.loading) {
        if(this.props.section.comments.pageInfo.hasNextPage) {
          this.setState({
            loading: true
          });
          this.props.relay.setVariables({
            count: this.props.relay.variables.count + 20
          }, readyState => {
            if (readyState.done) {
              this.setState({
                loading: false
              })
            }
          });
        } else {
          if(!this.state.done) {
            this.setState({
              done: true
            });
          }
        }
      }
    }.bind(this));
  }
}

module.exports = Section;

/*
  Relay Container: Section
  Defines data need for this section
*/

var SectionContainer = Relay.createContainer(Section, {
    initialVariables: {
      count: 20,
      order: "-id"
    },
    fragments: {
        section: () => Relay.QL`
          fragment on Section {
            id,
            long_name,
            created_at,
            comments_count,
            votes_count,
            comments(first: $count, order: "-id") {
              edges {
                node {
                  id,
                  ${Comment.getFragment('comment')}
                }
              },
              pageInfo {
                hasNextPage
              }
            }
          }
        `
    }
});

module.exports = SectionContainer;
