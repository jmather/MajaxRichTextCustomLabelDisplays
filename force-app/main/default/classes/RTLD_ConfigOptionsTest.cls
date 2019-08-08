/**
 * Created by jmather on 2019-08-07.
 */

@IsTest
public with sharing class RTLD_ConfigOptionsTest {
    @IsTest
    static void GetDefaultValue() {
        RTLD_ConfigOptions options = new RTLD_ConfigOptions();

        List<RTLD_Entry__mdt> entries = RTLD_EntryDAO.getEntries();

        Test.startTest();

        VisualEditor.DataRow value = options.getDefaultValue();

        Test.stopTest();

        System.assertEquals(entries[0].MasterLabel, value.getLabel());
        System.assertEquals(entries[0].DeveloperName, value.getValue());
    }

    @IsTest
    static void GetValues() {
        RTLD_ConfigOptions options = new RTLD_ConfigOptions();

        List<RTLD_Entry__mdt> entries = RTLD_EntryDAO.getEntries();

        Test.startTest();

        VisualEditor.DynamicPickListRows rowHolder = options.getValues();

        Test.stopTest();

        List<VisualEditor.DataRow> rows = rowHolder.getDataRows();

        for (Integer i = 0; i < rows.size(); i++) {
            System.assertEquals(entries[i].MasterLabel, rows[i].getLabel());
            System.assertEquals(entries[i].DeveloperName, rows[i].getValue());
        }
    }
}