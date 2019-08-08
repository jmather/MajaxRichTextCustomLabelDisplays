/**
 * Created by jmather on 2019-07-29.
 */

public with sharing class RTLD_RenderedData {
    public String title;
    public String content;

    public RTLD_RenderedData(String title, String content) {
        this.title = title;
        this.content = content;
    }
}