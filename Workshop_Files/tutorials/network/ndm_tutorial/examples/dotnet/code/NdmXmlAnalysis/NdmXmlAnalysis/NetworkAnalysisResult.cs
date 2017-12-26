using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Oracle.Spatial.XmlNdmAnalysis
{
    public class NetworkAnalysisResult
    {
        private NetworkAnalysisRequestType requestObject = null;

        public NetworkAnalysisRequestType RequestObject
        {
            get { return requestObject; }
            set { requestObject = value; }
        }
        private NetworkAnalysisResponseType responseObject = null;

        public NetworkAnalysisResponseType ResponseObject
        {
            get { return responseObject; }
            set { responseObject = value; }
        }
        private string requestXml = null;

        public string RequestXml
        {
            get { return requestXml; }
            set { requestXml = value; }
        }
        private string responseXml = null;

        public string ResponseXml
        {
            get { return responseXml; }
            set { responseXml = value; }
        }


    }
}
