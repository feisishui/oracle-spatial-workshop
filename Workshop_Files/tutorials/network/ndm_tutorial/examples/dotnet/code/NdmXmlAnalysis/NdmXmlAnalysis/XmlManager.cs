using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml.Serialization;
using System.Xml;

namespace Oracle.Spatial.XmlNdmAnalysis
{

    public class XmlManager
    {

        private static XmlManager instance = null;

        public static XmlManager Instance
        {
            get 
            {
                if (instance == null)
                {
                    instance = new XmlManager();
                }
                return instance;
            }
        }


        private XmlManager()
        {
 
        }

        public object convertXmlToObject(Type expectedType, TextReader reader)
        {
            XmlSerializer serializer = new XmlSerializer(expectedType);
            object obj = serializer.Deserialize(reader);
            reader.Close();
            return obj;
        }

        public object convertXmlToObject(Type expectedType, string xml)
        {
            StringReader reader = new StringReader(xml);
            return convertXmlToObject(expectedType, reader);
        }

        public object convertXmlTemplateToObject(Type expectedType, string templatePath)
        {
            TextReader reader = new StreamReader(templatePath);
            return convertXmlToObject(expectedType, reader);
        }

        public string convertObjectToXml(object obj, Type type)
        {
            MemoryStream memoryStream = new MemoryStream();
            XmlTextWriter xmlTextWriter = new XmlTextWriter(memoryStream, Encoding.UTF8);
            XmlSerializer serializer = new XmlSerializer(typeof(NetworkAnalysisRequestType));
            serializer.Serialize(xmlTextWriter, obj);
            string result = Encoding.UTF8.GetString(memoryStream.ToArray());
            return result;
        }

        public void test()
        {
            NetworkAnalysisRequestType request = new NetworkAnalysisRequestType();
            request.networkName = "NAVTEQ_SF";
            NearestNeighborsRequestType nearestNeighbors = new NearestNeighborsRequestType();
            request.Item = nearestNeighbors;
            nearestNeighbors.startPoint = new PointOnNetType();
            nearestNeighbors.startPoint.ItemsElementName = new ItemsChoiceType[] { ItemsChoiceType.nodeID };
            nearestNeighbors.startPoint.Items = new object[] { 12090934 };
            nearestNeighbors.noOfNeighbors = 10;
            nearestNeighbors.subPathRequestParameter = new SubPathRequestParameterType();
            nearestNeighbors.subPathRequestParameter.geometry = true;
            nearestNeighbors.subPathRequestParameter.pathRequestParameter = new PathRequestParameterType();
            nearestNeighbors.subPathRequestParameter.pathRequestParameter.geometry = true;
        }
    }
}
