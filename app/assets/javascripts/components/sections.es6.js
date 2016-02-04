var React = require('react');
var Relay = require('react-relay');
var SectionPreview = require('./section_preview.es6.js');
var classNames = require('classnames');

/*
  Component: Sections
  Renders a collection of sections
*/

class Sections extends React.Component {
  constructor(props) {
   super(props);
   this._handleScrollLoad = this._handleScrollLoad.bind(this);
   this._loadFilter = this._loadFilter.bind(this);
   this.state = {loading: false, done: false, popular: false}
  }

  componentDidMount() {
    this._handleScrollLoad();
  }

  render() {
  	var classes = classNames({
  		'filter': true,
  		'active': this.state.popular
  	});
    const {root} = this.props;
    return (
      <div className="container">
        <div className="row">
          <div className="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1">
    			<div className="sections-filters">
    				<ul className="filters">
    					<li className={classes}>
    						<a onClick={this._loadFilter.bind(this, "popular", null)}>
    							Popular sections
    						</a>
    					</li>
    					<li>
    						<a onClick={this._loadFilter.bind(this, null, "-id")}>Reset</a>
    					</li>
    				</ul>
    			</div>
			{root.sections.edges.map(({node}) => (
				<SectionPreview key={node.id} section={node} root={root} />
			))}
          </div>
        </div>
        {this.state.loading ?  <div className="loadmore">
            <span className="fa fa-spin fa-spinner"></span>
          </div> : ''}
        {this.state.done ?  <div className="loadmore-done">
            <p>No more sections to load</p>
          </div> : ''}
      </div>
    );
  }

  _handleScrollLoad() {
    $(window).scroll(function() {
      if (App.scrolledToBottom() && !this.state.loading) {
        if(this.props.root.sections.pageInfo.hasNextPage) {
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

  _loadFilter(filter, order) {
  	this.setState({ popular: !this.state.popular })
  	this.props.relay.setVariables({
  	  filter: filter,
  	  order: order
  	});
  }
}

module.exports = Sections;

/*
  Relay Container: Sections
  Defines data need for this component
*/

var SectionsContainer = Relay.createContainer(Sections, {
    initialVariables: {
      count: 20,
      order: "-id",
      filter: null
    },
    fragments: {
      root: () => Relay.QL`
        fragment on Viewer {
          id,
          sections(first: $count, order: $order, filter: $filter) {
            edges {
              node {
                id,
                ${SectionPreview.getFragment('section')}
              }
            }
            pageInfo {
              hasNextPage
            }
          }
        }
      `
    }
});

module.exports = SectionsContainer;

