/**
 * Created by jmather on 2019-07-29.
 */

public with sharing class RTLD_RenderedData {
    public String title;
    public String content;

    public RTLD_RenderedData(List<String> text) {
        if (text.isEmpty()) {
            this.title = '';
            this.content = '';
            return;
        }

        if (text.size() == 1) {
            this.title = '';
            this.content = text[0];
            return;
        }

        this.title = text[0];
        this.content = text[1];
    }

    public RTLD_RenderedData(String title, String content) {
        this.title = title;
        this.content = content;
    }
}