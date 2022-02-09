# Knowledge Article Body Content for Experience Cloud

**As of:** Winter '22

**Authored By:** George Abboud 

**Last Updated:** 02/08/2022

**Reviews and Contributions:**

Manish Aggarwal



# Overview:  

![image](https://user-images.githubusercontent.com/8514282/153260975-144afb9b-7c9d-4005-85c4-c417d6b2dc75.png)

AppExchange Listing: 
https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FZFTAUA5



## Description:

The Article Body app has components that allow for displaying the rich text content of both lightning and classic knowledge articles, instead of the standard page layout display that shows more fields than potentially needed. 
The Lightning Knowledge component provides querying options by recordId, urlName, or articleNumber. Both the Lightning and Classic Knowledge components provide options to show/hide/style the Title, Article Number, and Total Number of Views, as well as showing / hiding voting capabilities for authenticated users is also possible.

### Disclaimer:

This package is free to use, but is not an official [salesforce.com](http://salesforce.com/) product, and should be considered a community project. The functionality is not officially tested or documented, and does not come with any support, warrantees, or updates. It is offered as-is.



## Configuration:

### For Lightning Knowledge 

Configure the custom metadata type “**Article Body Setting**” for Lightning:

* Go to Setup > Custom Metadata Types
* Next to Article Body Setting, click “Manage Records”
* You should see a record with a Label called “lightning”, click Edit next to that and enter the article object API name for that article. Example: Knowledge__kav
    * ![image](https://user-images.githubusercontent.com/8514282/153261182-2d220df0-3956-4bb6-a4bf-cc0bbfb61377.png)
* Then enter the API name for the Rich Text Area field(s) that contains the content / body of the article. Example: Body__c. For multiple fields, separate the API names with a comma, Example: Body__c, Summary__c, etc.
    * ![image](https://user-images.githubusercontent.com/8514282/153261260-f4ddbcaa-d508-499a-bd7c-0e9100fd922f.png)
* Click Save



Configure the **Article Body - Lightning** component in Community Builder as follows:

**Component Label**: Article Body - Lightning
**Component Aura API Name**: articleBody
**Component LWC API Name**: article-body
**Component Namespace**: articleBody
**Component Properties:**

|Property Label	|Aura Property API Name	|LWC Property API Name	|Type	|Description	|
|---	|---	|---	|---	|---	|
|Article API Name	|articleAPIName	|article-a-p-i-name	|String	|(Required) Choose the intended Article Version object API name. **Note**: Make sure this is whitelisted in the default Article Body Setting custom metadata type field called “Article API Name Whitelist“	|
|Article Body (Rich Text) Field API Name	|articleBodyAPIName	|article-body-a-p-i-name	|String	|(Required) Choose the intended Rich Text field API name on the Article Version object previously selected. **Note**: Make sure this is whitelisted in the default Article Body Setting custom metadata type field called “Article Body Field API Name Whitelist“	|
|Article Body (Rich Text) Field API Name 2	|articleBodyAPIName2	|article-body-a-p-i-name2	|String	|Choose the second intended Rich Text field API name on the Article Version object previously selected. **Note**: Make sure this is whitelisted in the default Article Body Setting custom metadata type field called “Article Body Field API Name Whitelist“	|
|Display Second Body Field	|showSecondBodyField	|show-second-body-field	|	|If checked will display the article's second body field.	|
|Query By	|queryBy	|query-by	|String	|(Required) Select the field for which the article will be queried / filtered on. Options are recordId, urlName, articleNumber	|
|Record Id	|recordId	|record-id	|String	|If “recordId” is selected for **Query By** then this field must be populated with either a merge field that passes the article record id, or a hardcoded article record id. **Examples**: {!recordId}, ka05w000000EXd4AAG	|
|URL Name	|urlName	|url-name	|String	|If “urlName” is selected for **Query By** then this field must be populated with either a merge field that passes the article urlName (if available), or a hardcoded article urlName. **Examples**: {!urlName}, Test-Article-1	|
|Article Number	|articleNumber	|article-number	|String	| If “articleNumber” is selected for **Query By** then this field must be populated with either a merge field that passes the article number (if available), or a hardcoded article number. **Examples**: {!articleNumber}, 000001000	|
|Show Title	|showTitle	|show-title	|Boolean	|Check to show the title of the article, uncheck to hide title of the article.	|
|Title Style	|titleStyle	|title-style	|String	|CSS to apply to the title markup. **Example**: font-size: 26px;	|
|Show Article Number	|showArticleNumber	|show-article-number	|Boolean	|Check to show the article number, uncheck to hide the article number.	|
|Article Number Style	|articleNumberStyle	|article-number-style	|String	|CSS to apply to the article number markup. **Example**: font-size: 14px;	|
|Article Number Text	|articleNumberText	|article-number-text	|String	|Text Label to precede the article number: **Example**: ARTICLE NUMBER: 	|
|Show Article Views	|showArticleViews	|show-article-views	|Boolean	|Check to show the article total views, uncheck to hide the article total views.	|
|Article Views Style	|articleViewsStyle	|article-views-style	|String	|CSS to apply to the article total views markup. **Example**: font-size: 14px;	|
|Article Views Text	|articleViewsText	|article-views-text	|String	|Text Label to precede the article total views: **Example**: VIEWS: 	|
|Show Topics	|showTopics	|show-topics	|Boolean	|If checked will display article topics section.	|
|Show Voting	|showVoting	|show-voting	|Boolean	|Check to show voting options on article for authenticated users, uncheck to hide voting options for everyone.	|
|Replace Smart Links	|replaceSmartLinks	|replace-smart-links	|Boolean	|If checked attempt to replace smart links.	|
|Smart Links Url Path	|smartLinksUrlPath	|smart-links-url-path	|String	|Url Path for Smart Links. Example: /articles/Knowledge/ (include '/' at start and end)	|
|Article Page Url	|articlePageUrl	|article-page-url	|String	|Article Page Url in your site. Example: if your article page is /article/some-article-name then the page url is 'article'	|
|	|	|	|	|	|

### Usage in Aura

```
<articleBody:articleBody 
    queryBy="{!v.queryBy}" 
    articleAPIName="{!v.articleAPIName}" 
    articleBodyAPIName="{!v.articleBodyAPIName}" 
    articleBodyAPIName2="{!v.articleBodyAPIName2}"
    showSecondBodyField="{!v.showSecondBodyField}"
    showTitle="{!v.showTitle}"
    recordId="{!v.recordId}" 
    urlName="{!v.urlName}" 
    articleViewsText="{!v.articleViewsText}" 
    articleViewsStyle="{!v.articleViewsStyle}" 
    showArticleViews="{!v.showArticleViews}"
    showTopics="{!v.showTopics}"
    showVoting="{!v.showVoting}"
    replaceSmartLinks="{!v.replaceSmartLinks}"
    smartLinksUrlPath="{!v.smartLinksUrlPath}"
    articlePageUrl="{!v.articlePageUrl}"
/>
```



### For Classic Knowledge

Configure the custom metadata type “**Article Body Setting**” for Classic:

* Go to Setup > Custom Metadata Types
* Next to Article Body Setting, click “Manage Records”
* Select New and fill out the form setting the Label, Identifier, and Article API Name Whitelist fields to the Article Type’s API name. Example: FAQ__kav
    * ![image](https://user-images.githubusercontent.com/8514282/153261370-162c52be-8d40-4323-a831-9c3b8a27c56e.png)
* Set the Article Body Field API Name to the API name of the Rich Text Area field(s) on the article that contains the Content / Body of the article. For multiple fields, separate the API names with a comma, Example: Body__c, Summary__c, etc.
    * ![image](https://user-images.githubusercontent.com/8514282/153261450-d0ddddfd-0c51-445d-881d-150139eb6871.png)
* Click Save



Configure the **Article Body - Classic** component Community Builder as follows:

**Component Label**: Article Body - Classic
**Component Aura API Name**: articleBodyClassic
**Component LWC API Name**: article-body-classic
**Component Namespace**: articleBody
**Component Properties:**

|Property Label	|Aura Property API Name	|LWC Property API Name	|Type	|Description	|
|---	|---	|---	|---	|---	|
|Record Id	|recordId	|record-id	|String	|(Required)  This field must be populated with either a merge field that passes the article record id, or a hardcoded article record id. **Examples**: {!recordId}, ka05w000000EXd4AAG	|
|Display Second Body Field	|showSecondBodyField	|show-second-body-field	|	|If checked will display the article's second body field.	|
|Show Title	|showTitle	|show-title	|Boolean	|Check to show the title of the article, uncheck to hide title of the article.	|
|Title Style	|titleStyle	|title-style	|String	|CSS to apply to the title markup. **Example**: font-size: 26px;	|
|Show Article Number	|showArticleNumber	|show-article-number	|Boolean	|Check to show the article number, uncheck to hide the article number.	|
|Article Number Style	|articleNumberStyle	|article-number-style	|String	|CSS to apply to the article number markup. **Example**: font-size: 14px;	|
|Article Number Text	|articleNumberText	|article-number-text	|String	|Text Label to precede the article number: **Example**: ARTICLE NUMBER: 	|
|Show Article Views	|showArticleViews	|show-article-views	|Boolean	|Check to show the article total views, uncheck to hide the article total views.	|
|Article Views Style	|articleViewsStyle	|article-views-style	|String	|CSS to apply to the article total views markup. **Example**: font-size: 14px;	|
|Article Views Text	|articleViewsText	|article-views-text	|String	|Text Label to precede the article total views: **Example**: VIEWS: 	|
|Show Topics	|showTopics	|show-topics	|Boolean	|If checked will display article topics section.	|
|Show Voting	|showVoting	|show-voting	|Boolean	|Check to show voting options on article for authenticated users, uncheck to hide voting options for everyone.	|


**Note 1**: You have to explicitly grant access to the following apex controller for every profile that will be running this component, including the guest user profile: articleBody__ArticleController

**Note 2:** This app is LWR-Ready!



## Release Log: 

### Version 1.20

Installation URL:  https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000004ciMz

* Added support for Smart Links
* Fix for voting methods resulting in query errors



### Version 1.10 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000005CsSb

* Fix for displaying articles in draft. Only system administrators or user with modify all data permissions can view draft articles now. Otherwise the article must be published to display in the component.



### Version 1.9 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000005CrMC 

* Fixes to update view stat counts on articles when queried



### Version 1.8 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000005CrM7 

* Added support to display an optional second rich text field, below the first required one. 
* Added support to show assigned topics
* Added RelaxedCSP Capability



### Version 1.6 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000000asSi 

* Updated controller to global due to issue with recent security update that does not allow granting permission to lightning controllers in managed packages, unless they’re declared as global.



### Version 1.5 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000002lCMk

* Fixed issue with inability for the guest user to query the Vote object. Query was not necessary for guest users.



### Version 1.4 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000002kN2P 

* Added disable-linkify on formatted rich text that handles displaying article body / html content. Linkifying was causing issues with formatted code in article content.



### Version 1.3 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000002kEJ6 

* Added separate component for Classic Knowledge, with controller changes to support that.



### Version 1.2 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000002kEJ1 

* Fixed default custom metadata type article API Name value



### Version 1.1 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000002kChq

* Moved custom labels to custom metadata types for ease of modification in subscriber org



### Version 1.0 (DEPRECATED)

Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5w000002k9RH 

* Initial Release










