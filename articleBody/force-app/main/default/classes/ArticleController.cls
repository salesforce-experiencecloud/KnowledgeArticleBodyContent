/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class ArticleController {
    
    @AuraEnabled(cacheable=true)
    global static String getArticleInfoLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName)
    {
        return getArticleInfoLightning(recordId, urlName, articleNumber, queryBy, articleAPIName, articleBodyAPIName, null);
    }

    @AuraEnabled(cacheable=true)
    global static String getArticleInfoLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName, String articleBodyAPIName2)
    {
        return getArticleInfoLightning(recordId, urlName, articleNumber, queryBy, articleAPIName, articleBodyAPIName, articleBodyAPIName2, false);
    } 


    @AuraEnabled(cacheable=true)
    global static String getArticleInfoLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName, String articleBodyAPIName2, Boolean initial) 
    {
        Set<String> articleBodyAPINameSet = new Set<String>();
        articleBodyAPINameSet.add(articleBodyAPIName);
        if(articleBodyAPIName2 != null && articleBodyAPIName2.trim() != '') 
        {
            articleBodyAPINameSet.add(articleBodyAPIName2);
        }
        Map<String,Object> articleInfoMap = new Map<String,Object>();

        Boolean isArticleNameValid = validateArticleAPINames(articleAPIName, 'article');

        Boolean isArticleFieldNameValid = validateArticleAPINames(articleBodyAPIName, 'field');

        Boolean isArticleFieldNameValid2 = (articleBodyAPIName2 != null && articleBodyAPIName2.trim() != '') ? validateArticleAPINames(articleBodyAPIName2, 'field') : true;

        if(!isArticleNameValid || !isArticleFieldNameValid || !isArticleFieldNameValid2) 
        {
            return System.JSON.serialize(articleInfoMap);
        }

        SObject currArticle = getArticle(recordId, urlName, articleNumber, queryBy, articleAPIName, articleBodyAPINameSet, initial);
        
        articleInfoMap.put('siteUrl', System.Site.getBaseUrl());

        if(currArticle != null) 
        {
             
            articleInfoMap.put('body', (System.Test.isRunningTest()) ? '' : String.valueOf(currArticle.get(articleBodyAPIName)));
            articleInfoMap.put('body2', (System.Test.isRunningTest() || articleBodyAPIName2 == null || articleBodyAPIName2.trim() == '') ? '' : String.valueOf(currArticle.get(articleBodyAPIName2)));
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

            List<TopicAssignment> topicAssignments = getTopicAssignments(currArticle.Id);
            if(topicAssignments!= null && topicAssignments.size() > 0)
            {
                articleInfoMap.put('topicAssignments', topicAssignments);
            }        
            
        }
        else 
        {
            return null;
        }

        return System.JSON.serialize(articleInfoMap);

    }

    @AuraEnabled(cacheable=true)
    global static String getArticleInfoClassic(Id recordId) 
    {
        return getArticleInfoClassic(recordId, false);
    }

    @AuraEnabled(cacheable=true)
    global static String getArticleInfoClassic(Id recordId, Boolean initial) 
    {
        
        Map<String,Object> articleInfoMap = new Map<String,Object>();

        String articleAPIName = recordId.getSObjectType().getDescribe().getName();
        Set<String> articleBodyAPINameSet = getArticleBodyFieldAPINameClassic(articleAPIName);
        List<String> articleBodyAPINameList = new List<String>(articleBodyAPINameSet);
        SObject currArticle = getArticle(recordId, '', '', 'recordId', articleAPIName, articleBodyAPINameSet, initial);
        articleInfoMap.put('siteUrl', System.Site.getBaseUrl());

        if(currArticle != null) 
        {
             
            articleInfoMap.put('body', (System.Test.isRunningTest()) ? '' : String.valueOf(currArticle.get(articleBodyAPINameList[0])));
            articleInfoMap.put('body2', (System.Test.isRunningTest() || articleBodyAPINameSet.size() < 2) ? '' : String.valueOf(currArticle.get(articleBodyAPINameList[1])));
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

            List<TopicAssignment> topicAssignments = getTopicAssignments(currArticle.Id);
            if(topicAssignments!= null && topicAssignments.size() > 0)
            {
                articleInfoMap.put('topicAssignments', topicAssignments);
            }    
            
        }
        else 
        {
            return null;
        }

        return System.JSON.serialize(articleInfoMap);

    }

    @AuraEnabled
    global static String voteUpLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName) 
    {
        return voteUpLightning(recordId, urlName, articleNumber, queryBy, articleAPIName, articleBodyAPIName, null);
    }

    @AuraEnabled
    global static String voteUpLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName, String articleBodyAPIName2) 
    {
        Set<String> articleBodyAPINameSet = new Set<String>();
        articleBodyAPINameSet.add(articleBodyAPIName);
        if(articleBodyAPIName2 != null && articleBodyAPIName2.trim() != '') 
        {
            articleBodyAPINameSet.add(articleBodyAPIName2);
        }
        Map<String,String> articleVoteInfoMap = new Map<String,String>();

        Boolean isArticleNameValid = validateArticleAPINames(articleAPIName, 'article');

        Boolean isArticleFieldNameValid = validateArticleAPINames(articleBodyAPIName, 'field');

        Boolean isArticleFieldNameValid2 = (articleBodyAPIName2 != null && articleBodyAPIName2.trim() != '') ? validateArticleAPINames(articleBodyAPIName2, 'field') : true;

        if(!isArticleNameValid || !isArticleFieldNameValid || !isArticleFieldNameValid2) 
        {
            return System.JSON.serialize(articleVoteInfoMap);
        }
        
        try {

            createVote(recordId, urlName, articleNumber, queryBy, '5', articleAPIName, articleBodyAPINameSet);
            articleVoteInfoMap.put('result','success');

        } catch(Exception e) {System.debug(e);}

        return System.JSON.serialize(articleVoteInfoMap);

    }

    @AuraEnabled
    global static String voteUpClassic(Id recordId) 
    {
        
        Map<String,String> articleVoteInfoMap = new Map<String,String>();

        String articleAPIName = recordId.getSObjectType().getDescribe().getName();
        Set<String> articleBodyAPINameSet = getArticleBodyFieldAPINameClassic(articleAPIName);
        
        try {

            createVote(recordId, '', '', 'recordId', '5', articleAPIName, articleBodyAPINameSet);
            articleVoteInfoMap.put('result','success');

        } catch(Exception e) {System.debug(e);}

        return System.JSON.serialize(articleVoteInfoMap);

    }

    @AuraEnabled
    global static String voteDownLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName) 
    {
        return voteDownLightning(recordId, urlName, articleNumber, queryBy, articleAPIName, articleBodyAPIName, null);
    }

    @AuraEnabled
    global static String voteDownLightning(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName, String articleBodyAPIName2) 
    {
        Set<String> articleBodyAPINameSet = new Set<String>();
        articleBodyAPINameSet.add(articleBodyAPIName);
        if(articleBodyAPIName2 != null && articleBodyAPIName2.trim() != '') 
        {
            articleBodyAPINameSet.add(articleBodyAPIName2);
        }
        Map<String,String> articleVoteInfoMap = new Map<String,String>();

        Boolean isArticleNameValid = validateArticleAPINames(articleAPIName, 'article');

        Boolean isArticleFieldNameValid = validateArticleAPINames(articleBodyAPIName, 'field');

        Boolean isArticleFieldNameValid2 = (articleBodyAPIName2 != null && articleBodyAPIName2.trim() != '') ? validateArticleAPINames(articleBodyAPIName2, 'field') : true;

        if(!isArticleNameValid || !isArticleFieldNameValid || !isArticleFieldNameValid2) 
        {
            return System.JSON.serialize(articleVoteInfoMap);
        }
        
        try {

            createVote(recordId, urlName, articleNumber, queryBy, '1', articleAPIName, articleBodyAPINameSet);
            articleVoteInfoMap.put('result','success');

        } catch(Exception e) {System.debug(e);}
        
        return System.JSON.serialize(articleVoteInfoMap);

    }

    @AuraEnabled
    global static String voteDownClassic(Id recordId) 
    {
        
        Map<String,String> articleVoteInfoMap = new Map<String,String>();

        String articleAPIName = recordId.getSObjectType().getDescribe().getName();
        Set<String> articleBodyAPINameSet = getArticleBodyFieldAPINameClassic(articleAPIName);
        
        try {

            createVote(recordId, '', '', 'recordId', '1', articleAPIName, articleBodyAPINameSet);
            articleVoteInfoMap.put('result','success');

        } catch(Exception e) {System.debug(e);}

        return System.JSON.serialize(articleVoteInfoMap);

    }

    private static List<TopicAssignment> getTopicAssignments(Id recordId)
    {
        String query = 'SELECT Id, TopicId, Topic.Name FROM TopicAssignment WHERE EntityId = \'' + recordId + '\'';
        query += (System.Test.isRunningTest()) ? '' : ' AND NetworkId = \'' + System.Network.getNetworkId() + '\'';
        query += ' LIMIT 50';
        return System.Database.query(query);
    }

    private static void createVote(String recordId, String urlName, String articleNumber, String queryBy, String voteNumber, String articleAPIName, Set<String> articleBodyAPINameSet)
    {

        SObject currArticle = getArticle(recordId, urlName, articleNumber, queryBy, articleAPIName, articleBodyAPINameSet, false);

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

    private static SObject getArticle(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, Set<String> articleBodyAPINameSet, Boolean updateViewStat) 
    {

        Map<String,String> articleInfoMap = new Map<String,String>();

        String fields = getArticleFields(articleBodyAPINameSet);
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

            if(!isAdmin())
            {
                query += ' AND PublishStatus = \'Online\'';
            }

            query += (updateViewStat) ? ' UPDATE VIEWSTAT' : '';   
            system.debug('Query: ' + query);
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

    private static String getArticleFields(Set<String> articleBodyAPINameSet)
    {
        String fields = 'Title, KnowledgeArticleId, ArticleTotalViewCount, ArticleNumber';
        if(System.Test.isRunningTest()){return fields;}
        for(String s : articleBodyAPINameSet)
        {
            if(s.trim() != '')
            {
                fields +=  ',' + s.trim();
            }
        }
        return fields;
    }

    private static Set<String> getArticleBodyFieldAPINameClassic(String articleAPIName)
    {
        Set<String> articleBodyFieldAPINameSet = new Set<String>();
        if(System.Test.isRunningTest()) {return articleBodyFieldAPINameSet;}
        for(String s : getArticleBodySettings(articleAPIName).articleBody__Article_Body_Field_API_Name_Whitelist__c.split(','))
        {
            articleBodyFieldAPINameSet.add(s.trim());
        }
        return articleBodyFieldAPINameSet;
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

    private static Boolean isAdmin()
    {
        return [SELECT Id FROM Profile WHERE Id = :System.UserInfo.getProfileId() AND (Name = 'System Administrator' OR PermissionsModifyAllData = TRUE)].size() > 0;
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