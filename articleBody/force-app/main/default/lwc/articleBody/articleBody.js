import { LightningElement, api, track, wire } from 'lwc';
import fetchArticleInfo from '@salesforce/apex/ArticleController.getArticleInfo';
import voteUp from '@salesforce/apex/ArticleController.voteUp';
import voteDown from '@salesforce/apex/ArticleController.voteDown';
import { refreshApex } from '@salesforce/apex';


export default class ArticleBody extends LightningElement {
    @api articleAPIName = '';
    @api articleBodyAPIName = '';
    @api queryBy = '';
    @api recordId = '';
    @api urlName = '';
    @api articleNumber = '';
    @api showTitle = false;
    @api titleStyle = '';
    @api showVoting = false;
    @api showArticleNumber = false;
    @api articleNumberStyle = '';
    @api articleNumberText = '';
    @api showArticleViews = false;
    @api articleViewsStyle = '';
    @api articleViewsText = '';

    @track articleInfo;
    @track error;
    @track upVoteVariant = '';
    @track downVoteVariant = '';

    @api
    get displayVoting()
    {
        return (this.showVoting && this.articleInfo !== undefined && this.articleInfo.isGuest === 'false');
    }

    @api
    get showArticleAdditionalInfo()
    {
        return (this.showArticleNumber || this.showArticleViews);
    }

    @api
    get showHeaderTemplate()
    {
        return (this.showArticleNumber || this.showArticleViews || this.showTitle);
    }

    //wire functions
    wireArticleInfo;
    @wire(fetchArticleInfo,{recordId: '$recordId', urlName: '$urlName', articleNumber: '$articleNumber', queryBy: '$queryBy', articleAPIName: '$articleAPIName', articleBodyAPIName: '$articleBodyAPIName'})
    imperativeWiring(result) 
    {
        if (result.data) {
            this.wireArticleInfo = result;
            this.articleInfo = JSON.parse(result.data);
            this.error = undefined;
            this.upVoteVariant = '';
            this.downVoteVariant = '';
            if(this.articleInfo.userVote === '5')
            {
                this.upVoteVariant = 'brand';
            }
            else if(this.articleInfo.userVote === '1')
            {
                this.downVoteVariant = 'brand';
            }
            
        } else if (result.error) {
            if(window.location.host.indexOf('sitepreview') > 0 || window.location.host.indexOf('livepreview') > 0 || window.location.host.indexOf('live.') > 0)
            {
                this.error = result.error.body.message;
                this.error += ' Ensure that the article whitelist custom labels (articleBodyFieldAPINameWhitelist and articleAPINameWhitelist) are configured with the correct Article object API Name, and the Article Body field API Name.';
            }
            else 
            {
                this.error = 'Something has gone wrong! Please notify your administrator.';
            }
            this.articleInfo = undefined;
        }
    }

    handleUpVote(e)
    {
        
        voteUp({
            recordId: this.recordId,
            urlName: this.urlName,
            articleNumber: this.articleNumber,
            queryBy: this.queryBy,
            articleAPIName: this.articleAPIName, 
            articleBodyAPIName: this.articleBodyAPIName
        })
        .then(() => {
            return refreshApex(this.wireArticleInfo);
        })
        .catch((error) => {
            this.error = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
        

    }

    handleDownVote(e)
    {

        voteDown({
            recordId: this.recordId,
            urlName: this.urlName,
            articleNumber: this.articleNumber,
            queryBy: this.queryBy,
            articleAPIName: this.articleAPIName, 
            articleBodyAPIName: this.articleBodyAPIName
        })
        .then(() => {
            return refreshApex(this.wireArticleInfo);
        })
        .catch((error) => {
            this.error = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
        return refreshApex(this.wireArticleInfo);

    }

}