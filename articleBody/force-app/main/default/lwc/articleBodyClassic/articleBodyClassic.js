import { LightningElement, api, track, wire } from 'lwc';
import fetchArticleInfo from '@salesforce/apex/ArticleController.getArticleInfoClassic';
import voteUp from '@salesforce/apex/ArticleController.voteUpClassic';
import voteDown from '@salesforce/apex/ArticleController.voteDownClassic';
import { refreshApex } from '@salesforce/apex';


export default class ArticleBody extends LightningElement {

    @api recordId = '';
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
    @wire(fetchArticleInfo,{recordId: '$recordId'})
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
                this.error += (this.error.indexOf('Article Body Settings') > 0) ? ' \nEnsure that the default Article Body Settings custom metadata type is configured to whitelist the correct Article object API Name, and map the Article Body field API Name.' : '';
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
            recordId: this.recordId
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
            recordId: this.recordId
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