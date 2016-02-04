var React = require('react');
var Relay = require('react-relay');
var classNames = require('classnames');
import SectionVoteMutation from '../mutations/vote/section_vote_mutation.es6.js';
import SectionUnVoteMutation from '../mutations/vote/section_unvote_mutation.es6.js';

/*
/*
  Component: SectionPreview
  Renders a section preview
*/

class SectionPreview extends React.Component {
  constructor(props) {
   super(props);
   this._handleVote = this._handleVote.bind(this);
  }

  render() {
    var {section} = this.props;
    console.log(this.props);
    
    var voted = classNames({
      'fa fa-thumbs-up voted': this.props.section.voted,
      'fa fa-thumbs-o-up': !this.props.section.voted
    });

    return (
        <div className="section-preview">
          <a>
              <h2 className="section-title">
                { section.long_name }
              </h2>
              <div className="section-body" dangerouslySetInnerHTML={{__html: section.long_name }} />
          </a>
          <p className="section-meta">
            <span className="author">
                Taught by:
            </span>
            <span className="date">
              | { LocalTime.relativeTimeAgo(new Date(section.created_at)) }
            </span>
            <span className="count comments">
              <span>|</span> Comments: { section.comments_count }
            </span>
            <span className="count votes">
              <span>|</span>
              <a onClick={this._handleVote}>
                <span className={voted}></span>
              </a>
               { section.votes_count }
            </span>
          </p>
        </div>
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

}

module.exports = SectionPreview;

/*
  Relay Container: Section Preview
  Defines data need for this component
*/

var SectionContainer = Relay.createContainer(SectionPreview, {
	initialVariables: {
	  count: 1000
	},
    fragments: {
        section: () => Relay.QL`
          fragment on Section {
            id,
            long_name,
            created_at,
            comments_count,
            votes_count
          }
        `
    }
});

module.exports = SectionContainer;
