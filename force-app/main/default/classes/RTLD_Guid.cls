/**
 * Created by jmather on 2019-07-27.
 */

public with sharing class RTLD_Guid {
    public static String generateId() {
        return generate().replace('-', '_');
    }

    public static String generate() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        return h.substring(0,8)+ '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);
    }
}