global without sharing class RTLD_ConfigOptions extends VisualEditor.DynamicPicklist {
    static List<RTLD_Entry__mdt> entries = RTLD_EntryDAO.getEntries();
    
    global override VisualEditor.DataRow getDefaultValue() {
        if (entries.isEmpty()) {
            return null;
        }

        return createRow(entries[0]);
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();

        for (RTLD_Entry__mdt entry : entries) {
            values.addRow(createRow(entry));
        }

        return values;
    }

    private VisualEditor.DataRow createRow(RTLD_Entry__mdt entry) {
        return new VisualEditor.DataRow(entry.MasterLabel, entry.DeveloperName);
    }
}
