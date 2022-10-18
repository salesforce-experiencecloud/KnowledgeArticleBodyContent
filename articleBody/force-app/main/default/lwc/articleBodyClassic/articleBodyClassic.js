/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

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
    @api hideFirstBodyField = false;
    @api showSecondBodyField = false;
    @api showTopics = false;
    @api body1CssClassesInput = '';
    @api body2CssClassesInput = '';

    @track articleInfo;
    @track error;
    @track upVoteVariant = '';
    @track downVoteVariant = '';
    @track initial = true;

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

    @api
    get body1CssClasses()
    {
        return this.body1CssClassesInput;
    }

    @api
    get body2CssClasses()
    {
        return 'slds-m-top_medium ' + this.body2CssClassesInput;
    }

    //wire functions
    wireArticleInfo;
    @wire(fetchArticleInfo,{recordId: '$recordId', initial: '$initial'})
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

            if(this.articleInfo.topicAssignments !== undefined && this.articleInfo.topicAssignments !== null 
                && this.articleInfo.topicAssignments.length > 0)
            {
                for(let i=0; i < this.articleInfo.topicAssignments.length;i++)
                {
                    this.articleInfo.topicAssignments[i].link = this.articleInfo.siteUrl + '/' + this.articleInfo.topicAssignments[i].TopicId;
                }
            }

            this.initial = false;
            
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