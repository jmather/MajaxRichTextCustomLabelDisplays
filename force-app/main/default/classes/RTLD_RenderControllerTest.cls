/**
 * Created by jmather on 2019-07-27.
 */
@IsTest
public with sharing class RTLD_RenderControllerTest {
    @IsTest
    static void TestRenderText() {
        String title = '{!$Label.Test_1}';
        String content = '{!$Label.Test_2}';

        PageReference ref = Page.RTLD_Render;
        Test.setCurrentPage(ref);

        ApexPages.currentPage().getParameters().put('title', title);
        ApexPages.currentPage().getParameters().put('content', content);

        Test.startTest();

        RTLD_RenderController controller = new RTLD_RenderController();

        String renderedTitle = controller.getRenderedTitle();
        String renderedContent = controller.getRenderedContent();

        Test.stopTest();

        System.assertEquals('Test 1', renderedTitle);
        System.assertEquals('Test 2', renderedContent);
    }
}