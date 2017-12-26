using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Collections.Specialized;
using System.IO;

namespace Oracle.Spatial.XmlNdmAnalysis
{
    public class NetworkAnalysisHttpClient
    {
        private string targetUrl = null;


        public NetworkAnalysisHttpClient() { }

        public string TargetUrl
        {
            get { return targetUrl; }
            set { targetUrl = value; }
        }


        public string requestNetworkAnalysis(string xmlRequest)
        {
            string result = null;
            WebRequest request = WebRequest.Create( new Uri(targetUrl));
            request.ContentType = "text/xml";
            request.Method = "POST";

            byte[] content = Encoding.ASCII.GetBytes(xmlRequest);
            request.ContentLength = content.Length;
            Stream stream = request.GetRequestStream();
            
            stream.Write(content, 0, content.Length);
            stream.Close();
            WebResponse response = request.GetResponse();
            if (response == null)
            {
                result = "No results";
            }
            else
            {
                StreamReader reader = new StreamReader(response.GetResponseStream());
                result = reader.ReadToEnd().Trim();
            }
            return result;

        }

    }
}
