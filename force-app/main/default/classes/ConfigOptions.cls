global without sharing class ConfigOptions extends VisualEditor.DynamicPicklist {
    static List<MAJAX__Display_Entry__mdt> entries = EntryDAO.getEntries();
    
    global override VisualEditor.DataRow getDefaultValue() {
        if (entries.isEmpty()) {
            return null;
        }

        return createRow(entries[0]);
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();

        for (MAJAX__Display_Entry__mdt entry : entries) {
            values.addRow(createRow(entry));
        }

        return values;
    }

    private VisualEditor.DataRow createRow(MAJAX__Display_Entry__mdt entry) {
        return new VisualEditor.DataRow(entry.MasterLabel, entry.DeveloperName);
    }
}
