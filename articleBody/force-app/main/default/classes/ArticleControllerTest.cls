@isTest
private class ArticleControllerTest {
    
    @isTest
    private static void default()
    { //Schema.getGlobalDescribe().get('Article__kav').getDescribe().fields.getMap().get('Body__c').getDescribe().isHtmlFormatted()

        String articleAPIName = [SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE '%__kav'][0].QualifiedApiName;
        String urlName = 'someuniqueurl'+System.now().getTime();
        sObject sObj = Schema.getGlobalDescribe().get(articleAPIName).newSObject();
        sObj.put('urlname',urlName);
        sObj.put('title','testarticletitle');

        insert sObj;

        System.Test.startTest();

        String articleInfoString = ArticleController.getArticleInfo(sObj.Id, '', '', 'recordId', articleAPIName, '');
        System.assert(articleInfoString.contains('body'));

        String articleVoteInfoString = ArticleController.voteDown(sObj.Id, '', '', 'recordId', articleAPIName, '');
        System.assert(articleVoteInfoString.contains('success'));

        articleVoteInfoString = ArticleController.voteUp(sObj.Id, '', '', 'recordId', articleAPIName, '');
        System.assert(articleVoteInfoString.contains('success'));

        articleInfoString = ArticleController.getArticleInfo('', urlName, '', 'urlName', articleAPIName, '');
        System.assert(articleInfoString.contains('5'));

        System.Test.stopTest();

    }


}