/*
 * Copyright (c) 2021, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global class articleAPINamePicklist extends VisualEditor.DynamicPickList{
    
    VisualEditor.DesignTimePageContext context;

    global articleAPINamePicklist(VisualEditor.DesignTimePageContext context) {
        this.context = context;
        }

    global override VisualEditor.DataRow getDefaultValue(){
        
        VisualEditor.DynamicPickListRows rowList =  getPicklistRows();
        if(rowList.size() > 0) 
        {
            return rowList.get(0);
        }

        return null;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        
        return getPicklistRows();
    }

    private static VisualEditor.DynamicPickListRows getPicklistRows() {
        List<EntityDefinition> entityDefinitionList = [SELECT DurableId,QualifiedApiName FROM EntityDefinition 
                                                        WHERE QualifiedApiName LIKE '%__kav' ORDER BY QualifiedApiName ASC];
        
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();        
        
        for(EntityDefinition e : entityDefinitionList)
        {
            VisualEditor.DataRow value = new VisualEditor.DataRow(e.QualifiedApiName,e.QualifiedApiName);
            myValues.addRow(value);
        }
        
        return myValues;
    }
        
}