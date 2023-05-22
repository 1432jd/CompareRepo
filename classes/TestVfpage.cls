public class TestVfpage {
    
      public static void TestVf(){
            String myId='a030w000008HwIQAA0';
		        PageReference pdf = Page.TestPage;
            pdf.getParameters().put('id',myId);
            Attachment at     =   new Attachment();
            at.Body           =   pdf.getContentAsPDF();
            at.ParentId       =   myId;
            insert at;
            System.debug('attats id is >>>'+at.Id);     
    }

  }