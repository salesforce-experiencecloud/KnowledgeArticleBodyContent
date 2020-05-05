@isTest
private class ArticleControllerTest {
    
    @isTest
    private static void defaultLighting()
    { 

        String articleAPIName = [SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE '%__kav'][0].QualifiedApiName;
        String urlName = 'someuniqueurl'+System.now().getTime();
        sObject sObj = Schema.getGlobalDescribe().get(articleAPIName).newSObject();
        sObj.put('urlname',urlName);
        sObj.put('title','testarticletitle');

        insert sObj;

        System.Test.startTest();

        String articleInfoString = ArticleController.getArticleInfoLightning(sObj.Id, '', '', 'recordId', articleAPIName, '');
        System.assert(articleInfoString.contains('body'));

        String articleVoteInfoString = ArticleController.voteDownLightning(sObj.Id, '', '', 'recordId', articleAPIName, '');
        System.assert(articleVoteInfoString.contains('success'));

        articleVoteInfoString = ArticleController.voteUpLightning(sObj.Id, '', '', 'recordId', articleAPIName, '');
        System.assert(articleVoteInfoString.contains('success'));

        articleInfoString = ArticleController.getArticleInfoLightning('', urlName, '', 'urlName', articleAPIName, '');
        System.assert(articleInfoString.contains('5'));

        System.Test.stopTest();

    }

    @isTest
    private static void defaultClassic()
    { 
        
        String articleAPIName = [SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE '%__kav'][0].QualifiedApiName;
        String urlName = 'someuniqueurl'+System.now().getTime();
        sObject sObj = Schema.getGlobalDescribe().get(articleAPIName).newSObject();
        sObj.put('urlname',urlName);
        sObj.put('title','testarticletitle');

        insert sObj;

        System.Test.startTest();

        String articleInfoString = ArticleController.getArticleInfoClassic(sObj.Id);
        System.assert(articleInfoString.contains('body'));

        String articleVoteInfoString = ArticleController.voteDownClassic(sObj.Id);
        System.assert(articleVoteInfoString.contains('success'));

        articleVoteInfoString = ArticleController.voteUpClassic(sObj.Id);
        System.assert(articleVoteInfoString.contains('success'));

        articleInfoString = ArticleController.getArticleInfoClassic(sObj.Id);
        System.assert(articleInfoString.contains('5'));

        System.Test.stopTest();

    }

    @IsTest
    private static void testErrors()
    {

        try {
            ArticleController.getArticleBodySettings('sometestarticlethatsnotthere');
        } catch(Exception e) {
            System.assert((e+'').containsIgnoreCase('Article Body Settings'));
        }

    }


}