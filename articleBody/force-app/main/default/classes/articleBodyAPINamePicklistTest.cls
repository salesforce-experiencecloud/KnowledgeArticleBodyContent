/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
private class articleBodyAPINamePicklistTest {
    
    public static testMethod void test_success_articleBodyAPINamePicklistTest()
    {
        articleBodyAPINamePicklist conp = new articleBodyAPINamePicklist(null);
        VisualEditor.DataRow dr = conp.getDefaultValue();
        VisualEditor.DynamicPickListRows dpr = conp.getValues();

        List<EntityDefinition> entityDefinitionList = [SELECT DurableId,QualifiedApiName FROM EntityDefinition 
                                                        WHERE QualifiedApiName LIKE '%__kav' ORDER BY QualifiedApiName ASC];
        Set<Id> entityDefinitionIdSet = new Set<Id>();
        for(EntityDefinition entDef : entityDefinitionList)
        {
            entityDefinitionIdSet.add(entDef.DurableId);
        }

        Integer countFields = [SELECT COUNT() FROM FieldDefinition WHERE EntityDefinitionId IN :entityDefinitionIdSet 
                                                    AND IsHtmlFormatted = true AND ExtraTypeInfo = 'richtextarea'];

        if(countFields == 0)
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