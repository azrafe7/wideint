package wi;

#if use_int
typedef WIntTools = wi.FakeWideIntTools;
#else
typedef WIntTools = wi.WideIntTools;
#end
