package org.swizframework.processors
{
	import helpers.metadata.MetadataTagHelper;
	
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.strictlyEqualTo;
	import org.swizframework.core.Bean;
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MethodParameter;
	import org.swizframework.reflection.TypeDescriptor;

	public class ViewProcessorTest
	{	
		[Rule]
		public var rule:MockolateRule = new MockolateRule();
		
		[Mock]
		public var mediatorBean:Bean;
		
		[Mock]
		public var viewBean:Bean;
		
		private var processor:ViewProcessor;
		
		private var metadataTagHelper:MetadataTagHelper;
		
		private var viewMediator:ViewMediator;
		
		private var view:View;
		
		private var viewTypeDescriptor:TypeDescriptor;
		
		[Before]
		public function setUp():void
		{
			processor = new ViewProcessor(["ViewAdded", "ViewRemoved", "ViewNavigator"]);
			metadataTagHelper = new MetadataTagHelper();
			
			viewMediator = new ViewMediator();
			stub(mediatorBean).getter("source").returns(viewMediator);
			
			view = new View();
			stub(viewBean).getter("source").returns(view);
			
			viewTypeDescriptor = new TypeDescriptor();
			viewTypeDescriptor.type = View;
			stub(viewBean).getter("typeDescriptor").returns(viewTypeDescriptor);
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTags test(s)
		//
		//------------------------------------------------------
		
		[Test(expects="Error")]
		public function setUpMetadataTags_viewAddedAnnotatingClass_throwsError():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewAdded", {}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS);
			processor.setUpMetadataTags([tag], mediatorBean);
		}
		
		[Test(expects="Error")]
		public function setUpMetadataTags_viewRemovedAnnotatingClass_throwsError():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewRemoved", {}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS);
			processor.setUpMetadataTags([tag], mediatorBean);
		}
		
		[Test(expects="Error")]
		public function setUpMetadataTags_viewNavigatorAnnotatingClass_throwsError():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewNavigator", {}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS);
			processor.setUpMetadataTags([tag], mediatorBean);
		}
		
		[Test]
		public function setUpMetadataTags_viewAddedAnnotatingPublicProperty_doesNotThrowError():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewAdded", {}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "view", View);
			processor.setUpMetadataTags([tag], mediatorBean);
		}
		
		[Test]
		public function setUpMetadataTags_viewRemovedAnnotatingPublicProperty_doesNotThrowError():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewRemoved", {}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "view", View);
			processor.setUpMetadataTags([tag], mediatorBean);
		}
		
		[Test]
		public function setUpMetadataTags_viewNavigatorAnnotatingPublicProperty_doesNotThrowError():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewNavigator", {}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "view", View);
			processor.setUpMetadataTags([tag], mediatorBean);
		}
		
		[Test]
		public function setUpMetadataTags_viewAddedAnnotatingPublicFunction_doesNotThrowError():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewAdded", {}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "viewAdded", View);
			processor.setUpMetadataTags([tag], mediatorBean);
		}
		
		[Test]
		public function setUpMetadataTags_viewRemovedAnnotatingPublicFunction_doesNotThrowError():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewRemoved", {}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "viewRemoved", View);
			processor.setUpMetadataTags([tag], mediatorBean);
		}
		
		[Test]
		public function setUpMetadataTags_viewNavigatorAnnotatingPublicFunction_doesNotThrowError():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewNavigator", {}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "viewNavigated", View);
			processor.setUpMetadataTags([tag], mediatorBean);
		}
		
		//------------------------------------------------------
		//
		// setUpBean tests
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpBean_viewAddedAnnotatingPublicProperty_setsView():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewAdded", {}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "view", View);
			processor.setUpMetadataTags([tag], mediatorBean);
			processor.setUpBean(viewBean);
			assertThat(viewMediator.view, strictlyEqualTo(view));
		}
		
		[Test]
		public function setUpBean_viewAddedAnnotatingMethod_setsView():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewAdded", {}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "viewAdded", View);
			processor.setUpMetadataTags([tag], mediatorBean);
			processor.setUpBean(viewBean);
			assertThat(viewMediator.view, strictlyEqualTo(view));
		}
		
		//------------------------------------------------------
		//
		// tearDownBean tests
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownBean_viewRemovedAnnotatingPublicProperty_setsView():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewRemoved", {}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "view", View);
			processor.setUpMetadataTags([tag], mediatorBean);
			processor.tearDownBean(viewBean);
			assertThat(viewMediator.view, strictlyEqualTo(view));
		}
		
		[Test]
		public function tearDownBean_viewRemovedAnnotatingMethod_setsView():void
		{
			var tag:IMetadataTag = createMetadataTag("ViewRemoved", {}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "viewRemoved", View);
			processor.setUpMetadataTags([tag], mediatorBean);
			processor.tearDownBean(viewBean);
			assertThat(viewMediator.view, strictlyEqualTo(view));
		}
		
		//------------------------------------------------------
		//
		// Miscellaneous test helper function(s)
		//
		//------------------------------------------------------
		
		private function createMetadataTag(tagName:String, args:Object, metadataHostType:String, hostName:String = null, hostType:Class = null):IMetadataTag
		{
			var tag:IMetadataTag = metadataTagHelper.createBaseMetadataTagWithArgs(tagName, args, metadataHostType, hostName, hostType);
			
			if ( metadataHostType == MetadataTagHelper.METADATA_HOST_TYPE_METHOD )
			{
				createHostParameterForFunction(tag.host, hostType);
			}
			
			return tag;
		}
		
		private function createHostParameterForFunction(host:IMetadataHost, hostType:Class):void
		{
			var hostMethod:MetadataHostMethod = MetadataHostMethod(host);
			hostMethod.parameters.push(new MethodParameter(0, hostType, false));
		}
	}
}

class ViewMediator
{
	public var view:View;
	
	public function viewAdded(view:View):void
	{
		this.view = view;	
	}
	
	public function viewRemoved(view:View):void
	{
		this.view = view;
	}
	
	public function viewNavigated(view:View):void
	{
		this.view = view;
	}
}

class View
{
	
}
	