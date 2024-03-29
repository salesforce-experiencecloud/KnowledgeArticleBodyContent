/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
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