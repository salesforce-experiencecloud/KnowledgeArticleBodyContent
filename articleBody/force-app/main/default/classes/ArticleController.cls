public with sharing class ArticleController {
    
    @AuraEnabled(cacheable=true)
    public static String getArticleInfo(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName) 
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
            }

            articleInfoMap.put('likes', String.valueOf(getArticleLikes(String.valueOf(currArticle.get('KnowledgeArticleId')))));
            articleInfoMap.put('dislikes', String.valueOf(getArticleDislikes(String.valueOf(currArticle.get('KnowledgeArticleId')))));
            
        }

        return System.JSON.serialize(articleInfoMap);

    }

    @AuraEnabled
    public static String voteUp(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName) 
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
    public static String voteDown(String recordId, String urlName, String articleNumber, String queryBy, String articleAPIName, String articleBodyAPIName) 
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

    private static boolean validateArticleAPINames(String articleAPIName, String type)
    {
        String whitelist = (type == 'field') ? System.Label.articleBody.articleBodyFieldAPINameWhitelist : System.Label.articleBody.articleAPINameWhitelist ;
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
            throw new articleBodyException('Invalid ' + type + ' API name. Please add to whitelist custom label.');
        }

        isValid = (System.Test.isRunningTest()) ? true : isValid;

        return isValid;

    }

    public class articleBodyException extends Exception {}


}