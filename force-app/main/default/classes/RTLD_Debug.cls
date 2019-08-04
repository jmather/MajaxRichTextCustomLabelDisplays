/**
 * Created by jmather on 2019-07-28.
 */

public with sharing class RTLD_Debug {
    public static Boolean enabled = true;

    public static void log(String text) {
        if (enabled == false) {
            return;
        }

        System.debug(text);
    }
}