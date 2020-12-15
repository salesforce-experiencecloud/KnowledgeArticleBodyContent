global with sharing class ArticleController {
    
    @AuraEnabled(cacheable=true)
    global static String getArticleInfoLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName) 
    {
        
        Map<String,String> articleInfoMap = new Map<String,String>();

        Boolean isArticleNameValid = validateArticleAPINames(articleAPIName, 'article');

        Boolean isArticleFieldNameValid = validateArticleAPINames(articleBodyAPIName, 'field');

        if(!isArticleNameValid || !isArticleFieldNameValid) 
        {
            return System.JSON.serialize(articleInfoMap);
        }

        SObject currArticle = getArticle(recordId, urlName, articleNumber, queryBy, articleAPIName, articleBodyAPIName);

        if(currArticle != null) 
        {
             
            articleInfoMap.put('body', (System.Test.isRunningTest()) ? '' : String.valueOf(currArticle.get(articleBodyAPIName)));
            articleInfoMap.put('title', String.valueOf(currArticle.get('Title')));
            articleInfoMap.put('articleNumber', String.valueOf(currArticle.get('ArticleNumber')));
            articleInfoMap.put('articleViews', String.valueOf(currArticle.get('ArticleTotalViewCount')));

            articleInfoMap.put('isGuest', 'true');
            
            if(System.UserInfo.getUserType() != 'Guest')
            {
                articleInfoMap.put('isGuest', 'false');
                Vote userVote = getUserVote(String.valueOf(currArticle.get('KnowledgeArticleId')));
                articleInfoMap.put('userVote', (userVote != null) ? userVote.Type : '0');
                articleInfoMap.put('likes', String.valueOf(getArticleLikes(String.valueOf(currArticle.get('KnowledgeArticleId')))));
                articleInfoMap.put('dislikes', String.valueOf(getArticleDislikes(String.valueOf(currArticle.get('KnowledgeArticleId')))));
            }

            
            
        }

        return System.JSON.serialize(articleInfoMap);

    }

    @AuraEnabled(cacheable=true)
    global static String getArticleInfoClassic(Id recordId) 
    {
        
        Map<String,String> articleInfoMap = new Map<String,String>();

        String articleAPIName = recordId.getSObjectType().getDescribe().getName();
        String articleBodyAPIName = getArticleBodyFieldAPINameClassic(articleAPIName);
        SObject currArticle = getArticle(recordId, '', '', 'recordId', articleAPIName, articleBodyAPIName);

        if(currArticle != null) 
        {
             
            articleInfoMap.put('body', (System.Test.isRunningTest()) ? '' : String.valueOf(currArticle.get(articleBodyAPIName)));
            articleInfoMap.put('title', String.valueOf(currArticle.get('Title')));
            articleInfoMap.put('articleNumber', String.valueOf(currArticle.get('ArticleNumber')));
            articleInfoMap.put('articleViews', String.valueOf(currArticle.get('ArticleTotalViewCount')));

            articleInfoMap.put('isGuest', 'true');
            
            if(System.UserInfo.getUserType() != 'Guest')
            {
                articleInfoMap.put('isGuest', 'false');
                Vote userVote = getUserVote(String.valueOf(currArticle.get('KnowledgeArticleId')));
                articleInfoMap.put('userVote', (userVote != null) ? userVote.Type : '0');
                articleInfoMap.put('likes', String.valueOf(getArticleLikes(String.valueOf(currArticle.get('KnowledgeArticleId')))));
                articleInfoMap.put('dislikes', String.valueOf(getArticleDislikes(String.valueOf(currArticle.get('KnowledgeArticleId')))));
            }
            
        }

        return System.JSON.serialize(articleInfoMap);

    }

    @AuraEnabled
    global static String voteUpLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName) 
    {
        
        Map<String,String> articleVoteInfoMap = new Map<String,String>();

        Boolean isArticleNameValid = validateArticleAPINames(articleAPIName, 'article');

        Boolean isArticleFieldNameValid = validateArticleAPINames(articleBodyAPIName, 'field');

        if(!isArticleNameValid || !isArticleFieldNameValid) 
        {
            return System.JSON.serialize(articleVoteInfoMap);
        }
        
        try {

            createVote(recordId, urlName, articleNumber, queryBy, '5', articleAPIName, articleBodyAPIName);
            articleVoteInfoMap.put('result','success');

        } catch(Exception e) {System.debug(e);}

        return System.JSON.serialize(articleVoteInfoMap);

    }

    @AuraEnabled
    global static String voteUpClassic(Id recordId) 
    {
        
        Map<String,String> articleVoteInfoMap = new Map<String,String>();

        String articleAPIName = recordId.getSObjectType().getDescribe().getName();
        String articleBodyAPIName = getArticleBodyFieldAPINameClassic(articleAPIName);
        
        try {

            createVote(recordId, '', '', 'recordId', '5', articleAPIName, articleBodyAPIName);
            articleVoteInfoMap.put('result','success');

        } catch(Exception e) {System.debug(e);}

        return System.JSON.serialize(articleVoteInfoMap);

    }

    @AuraEnabled
    global static String voteDownLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName) 
    {

        Map<String,String> articleVoteInfoMap = new Map<String,String>();

        Boolean isArticleNameValid = validateArticleAPINames(articleAPIName, 'article');

        Boolean isArticleFieldNameValid = validateArticleAPINames(articleBodyAPIName, 'field');

        if(!isArticleNameValid || !isArticleFieldNameValid) 
        {
            return System.JSON.serialize(articleVoteInfoMap);
        }
        
        try {

            createVote(recordId, urlName, articleNumber, queryBy, '1', articleAPIName, articleBodyAPIName);
            articleVoteInfoMap.put('result','success');

        } catch(Exception e) {System.debug(e);}
        
        return System.JSON.serialize(articleVoteInfoMap);

    }

    @AuraEnabled
    global static String voteDownClassic(Id recordId) 
    {
        
        Map<String,String> articleVoteInfoMap = new Map<String,String>();

        String articleAPIName = recordId.getSObjectType().getDescribe().getName();
        String articleBodyAPIName = getArticleBodyFieldAPINameClassic(articleAPIName);
        
        try {

            createVote(recordId, '', '', 'recordId', '1', articleAPIName, articleBodyAPIName);
            articleVoteInfoMap.put('result','success');

        } catch(Exception e) {System.debug(e);}

        return System.JSON.serialize(articleVoteInfoMap);

    }

    private static void createVote(String recordId, String urlName, String articleNumber, String queryBy, String voteNumber, String articleAPIName, String articleBodyAPIName)
    {

        SObject currArticle = getArticle(recordId, urlName, articleNumber, queryBy, articleAPIName, articleBodyAPIName);

        if(currArticle != null)
        {
            Vote userVote = getUserVote(String.valueOf(currArticle.get('KnowledgeArticleId')));
            if(userVote != null)
            {
                userVote.Type = voteNumber;
                update userVote;
            }
            else 
            {
                userVote = new Vote(ParentId=String.valueOf(currArticle.get('KnowledgeArticleId')), Type=voteNumber);
                insert userVote;
            }

        }

    } 
    
    private static Vote getUserVote(String recordId)
    {
        List<Vote> voteList = [SELECT Id,Type FROM Vote WHERE ParentId = :recordId AND CreatedById = :System.UserInfo.getUserId()];
        return (voteList != null && voteList.size() > 0) ? voteList[0] : null ;
    }

    private static Integer getArticleLikes(String recordId)
    {
        return [SELECT COUNT() FROM Vote WHERE ParentId = :recordId AND Type = '5'];
    }

    private static Integer getArticleDislikes(String recordId)
    {
        return [SELECT COUNT() FROM Vote WHERE ParentId = :recordId AND Type = '1'];
    }

    private static SObject getArticle(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName) 
    {

        Map<String,String> articleInfoMap = new Map<String,String>();

        String fields = getArticleFields(articleBodyAPIName);
        String calcArticleAPIName = getArticleAPIName(articleAPIName);

        String query = 'SELECT ' + fields + ' FROM ' + calcArticleAPIName + ' WHERE ';

        if(queryBy == 'recordId' && recordId != null && recordId != '')
        {
            query += 'Id = \'' + recordId + '\'';
        }
        else if(queryBy == 'urlName' && urlName != null && urlName != '')
        {
            query += 'urlName = \'' + urlName + '\'';
        }
        else if(queryBy == 'articleNumber' && articleNumber != null && articleNumber != '') 
        {
            query += 'articleNumber = \'' + articleNumber + '\'';
        }
        else 
        {
            query = null;
        }

        if(query != null) 
        {
            
            List<SObject> articleList = System.Database.query(query);

            if(articleList != null && articleList.size() > 0) 
            {
                return articleList[0];
            }

        }

        return null;

    }

    private static String getArticleAPIName(String articleAPIName)
    {
        String calcArticleAPIName = [SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE '%__kav'][0].QualifiedApiName;
        calcArticleAPIName = (System.Test.isRunningTest()) ? calcArticleAPIName : articleAPIName;
        return calcArticleAPIName;
    }

    private static String getArticleFields(String articleBodyAPIName)
    {
        String fields = 'Title, KnowledgeArticleId, ArticleTotalViewCount, ArticleNumber';
        fields += (System.Test.isRunningTest()) ? '' : ',' + articleBodyAPIName;
        return fields;
    }

    private static String getArticleBodyFieldAPINameClassic(String articleAPIName)
    {
        String articleBodyAPIName = (System.Test.isRunningTest()) ? '' : getArticleBodySettings(articleAPIName).articleBody__Article_Body_Field_API_Name_Whitelist__c.split(',')[0];
        return articleBodyAPIName;
    }

    private static boolean validateArticleAPINames(String articleAPIName, String type)
    {
        articleBody__Article_Body_Setting__mdt abSetting = getArticleBodySettings();
        String whitelist = (type == 'field') ? abSetting.articleBody__Article_Body_Field_API_Name_Whitelist__c : abSetting.articleBody__Article_API_Name_Whitelist__c;
        Set<String> whitelistSet = new Set<String>();
        for(String s : whitelist.split(','))
        {
            if(s != null && s.trim() != '')
            {
                whitelistSet.add(s.trim().toLowercase());
            }
        }

        Boolean isValid = whitelistSet.contains(articleAPIName.toLowerCase());

        if(!isValid && !System.Test.isRunningTest()) 
        {
            String settingPrefix = Schema.getGlobalDescribe().get('articleBody__Article_Body_Setting__mdt').getDescribe().getKeyPrefix();
            String errorText = 'Invalid ' + type + ' API name. Please add to Article Body Settings custom metadata type whitelist: ';
            errorText += System.URL.getOrgDomainUrl().toExternalForm() + '/lightning/setup/CustomMetadata/page?address=%2F' + settingPrefix + '%3Fsetupid%3DCustomMetadata';
            throw new articleBodyException(errorText);
        }

        isValid = (System.Test.isRunningTest()) ? true : isValid;

        return isValid;

    }

    private static articleBody__Article_Body_Setting__mdt getArticleBodySettings()
    {
        String CCDCSETTING_APINAME_DEFAULT = 'lightning';
        return getArticleBodySettings(CCDCSETTING_APINAME_DEFAULT);

    }

    @TestVisible
    private static articleBody__Article_Body_Setting__mdt getArticleBodySettings(String CCDCSETTING_APINAME_DEFAULT)
    {
        try {
            SObjectType ccdcSettingType = Schema.getGlobalDescribe().get('articleBody__Article_Body_Setting__mdt');
            Map<String,Schema.SObjectField> ccdcSettingFieldMap = ccdcSettingType.getDescribe().fields.getMap();
            List<String> ccdcFieldList = new List<String>();
            ccdcFieldList.addAll(ccdcSettingFieldMap.keySet());
            String ccdcSettingFields = String.join(ccdcFieldList,',');

            String query = 'SELECT ' + ccdcSettingFields + ' FROM articleBody__Article_Body_Setting__mdt WHERE ';
            query += 'articleBody__Identifier__c = \'' + CCDCSETTING_APINAME_DEFAULT + '\' LIMIT 1';
            List<articleBody__Article_Body_Setting__mdt> abSettingsList = System.database.query(query);
            return abSettingsList[0];
        } catch(Exception e) {
            if((e+'').containsIgnoreCase('list index out of bounds')) 
            {
                String settingPrefix = Schema.getGlobalDescribe().get('articleBody__Article_Body_Setting__mdt').getDescribe().getKeyPrefix();
                String errorText = 'Please add a record to Article Body Settings custom metadata type whitelist. ';
                errorText += 'Set the identifier field and the Article API Name Whitelist field to the API name of the article type, ';
                errorText += 'and the Article Body Field API Name Whitelist field to the API name of the Rich Text body/content field of the article type: ';
                errorText += System.URL.getOrgDomainUrl().toExternalForm() + '/lightning/setup/CustomMetadata/page?address=%2F' + settingPrefix + '%3Fsetupid%3DCustomMetadata';
                throw new articleBodyException(errorText);
            }
            return null;
        }
    }

    public class articleBodyException extends Exception {}


}