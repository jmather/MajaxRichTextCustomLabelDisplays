/**
 * Created by jmather on 2019-07-27.
 */
@IsTest
public with sharing class RTLD_RenderControllerTest {
    @IsTest
    static void TestRenderTransformableText() {
        String title = '{!$Label.Test_1}';
        String content = '{!$Label.Test_2}';

        PageReference ref = Page.RTLD_Render;
        Test.setCurrentPage(ref);

        ApexPages.currentPage().getParameters().put('title', title);
        ApexPages.currentPage().getParameters().put('content', content);
        ApexPages.currentPage().getParameters().put('debug', 'false');

        Test.startTest();

        RTLD_RenderController controller = new RTLD_RenderController();

        String encodedData = controller.getData();
        String jsonData = EncodingUtil.base64Decode(encodedData).toString();
        RTLD_RenderedData data = (RTLD_RenderedData) JSON.deserialize(jsonData, RTLD_RenderedData.class);

        Test.stopTest();

        System.assertEquals('Test 1', data.title);
        System.assertEquals('Test 2', data.content);
    }

    @IsTest
    static void TestRenderRegularText() {
        String title = 'Foo';
        String content = 'Bar';

        PageReference ref = Page.RTLD_Render;
        Test.setCurrentPage(ref);

        ApexPages.currentPage().getParameters().put('title', title);
        ApexPages.currentPage().getParameters().put('content', content);
        ApexPages.currentPage().getParameters().put('debug', 'false');

        Test.startTest();

        RTLD_RenderController controller = new RTLD_RenderController();

        String encodedData = controller.getData();
        String jsonData = EncodingUtil.base64Decode(encodedData).toString();
        RTLD_RenderedData data = (RTLD_RenderedData) JSON.deserialize(jsonData, RTLD_RenderedData.class);

        Test.stopTest();

        System.assertEquals('Foo', data.title);
        System.assertEquals('Bar', data.content);
    }

    @IsTest
    static void RenderNoContent() {
        String title = '';
        String content = '';

        PageReference ref = Page.RTLD_Render;
        Test.setCurrentPage(ref);

        ApexPages.currentPage().getParameters().put('title', title);
        ApexPages.currentPage().getParameters().put('content', content);
        ApexPages.currentPage().getParameters().put('debug', 'false');

        Test.startTest();

        RTLD_RenderController controller = new RTLD_RenderController();

        String encodedData = controller.getData();
        String jsonData = EncodingUtil.base64Decode(encodedData).toString();
        RTLD_RenderedData data = (RTLD_RenderedData) JSON.deserialize(jsonData, RTLD_RenderedData.class);

        Test.stopTest();

        System.assertEquals('Example Title', data.title);
        System.assertEquals('Example Content', data.content);
    }

    @IsTest
    static void TestRenderTitleEmpty() {
        String title = '';
        String content = 'Bar';

        PageReference ref = Page.RTLD_Render;
        Test.setCurrentPage(ref);

        ApexPages.currentPage().getParameters().put('title', title);
        ApexPages.currentPage().getParameters().put('content', content);
        ApexPages.currentPage().getParameters().put('debug', 'false');

        Test.startTest();

        RTLD_RenderController controller = new RTLD_RenderController();

        String encodedData = controller.getData();
        String jsonData = EncodingUtil.base64Decode(encodedData).toString();
        RTLD_RenderedData data = (RTLD_RenderedData) JSON.deserialize(jsonData, RTLD_RenderedData.class);

        Test.stopTest();

        System.assertEquals('', data.title);
        System.assertEquals('Bar', data.content);
    }

    @IsTest
    static void TestRenderContentEmpty() {
        String title = 'Foo';
        String content = '';

        PageReference ref = Page.RTLD_Render;
        Test.setCurrentPage(ref);

        ApexPages.currentPage().getParameters().put('title', title);
        ApexPages.currentPage().getParameters().put('content', content);
        ApexPages.currentPage().getParameters().put('debug', 'false');

        Test.startTest();

        RTLD_RenderController controller = new RTLD_RenderController();

        String encodedData = controller.getData();
        String jsonData = EncodingUtil.base64Decode(encodedData).toString();
        RTLD_RenderedData data = (RTLD_RenderedData) JSON.deserialize(jsonData, RTLD_RenderedData.class);

        Test.stopTest();

        System.assertEquals('Foo', data.title);
        System.assertEquals('', data.content);
    }
}