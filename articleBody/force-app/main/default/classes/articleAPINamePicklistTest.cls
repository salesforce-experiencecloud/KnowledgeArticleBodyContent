@isTest
private class articleAPINamePicklistTest {
    
    public static testMethod void test_success_articleAPINamePicklistTest()
    {
        articleAPINamePicklist conp = new articleAPINamePicklist(null);
        VisualEditor.DataRow dr = conp.getDefaultValue();
        VisualEditor.DynamicPickListRows dpr = conp.getValues();
        Integer countKavs = [SELECT COUNT() FROM EntityDefinition 
                            WHERE QualifiedApiName LIKE '%__kav'];
        if(countKavs == 0)
        {
            System.assertEquals(null,dr);
            System.assert(dpr.size() == 0);
        }
        else 
        {
            System.assertNotEquals(null,dr);
            System.assert(dpr.size() > 0);
        }
        
    }

}