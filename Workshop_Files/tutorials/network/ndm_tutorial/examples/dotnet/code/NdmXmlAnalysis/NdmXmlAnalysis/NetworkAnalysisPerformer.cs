using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Oracle.Spatial.XmlNdmAnalysis
{
    public class NetworkAnalysisPerformer
    {

        private const string NART_SHORTEST_PATH = "nar_shortest_path.xml";
        private const string NART_NEAREST_NEIGHBORS = "nar_nearest_neighbors.xml";
        private const string NART_WITHIN_COST = "nar_within_cost.xml";
        private const string NART_TSP = "nar_tsp.xml";

        private string templatesDir = null;

        private string networkAnalysisServiceUrl = null;

        private string networkName = null;

        public NetworkAnalysisPerformer(string networkAnalysisServiceUrl, string templatesDir, string networkName)
        {
            this.networkAnalysisServiceUrl = networkAnalysisServiceUrl;
            this.templatesDir = templatesDir;
            this.networkName = networkName;
        }

        protected NetworkAnalysisRequestType LoadRequestFromTemplate(NetworkAnalysisType naType)
        {
            //select the template to load base on the analysis type
            string templatePath = templatesDir;
            switch (naType)
            {
                case NetworkAnalysisType.ShortestPath:
                    templatePath += NART_SHORTEST_PATH;
                    break;
                case NetworkAnalysisType.NearestNeightbors:
                    templatePath += NART_NEAREST_NEIGHBORS;
                    break;
                case NetworkAnalysisType.Tsp:
                    templatePath += NART_TSP;
                    break;
                case NetworkAnalysisType.WithinCost:
                    templatePath += NART_WITHIN_COST;
                    break;
            }
            NetworkAnalysisRequestType nar = null;
            try
            {
                nar = (NetworkAnalysisRequestType)XmlManager.Instance.convertXmlTemplateToObject(
                    typeof(NetworkAnalysisRequestType), templatePath);
            }
            catch (Exception ex)
            {
                throw new Exception("Error loading XML from template: ["+templatePath+"]",ex);
            }
            return nar;
        }

        public NetworkAnalysisResult PerformShortestPathAnalysis(NetworkAnalysisRequestParams requestParams)
        {
            //Create an xml request object representation using a template
            NetworkAnalysisRequestType requestObject = LoadRequestFromTemplate(NetworkAnalysisType.ShortestPath);
            
            //Get the element for the type of request
            ShortestPathRequestType spr = (ShortestPathRequestType) requestObject.Item;

            //Add the user input values to the request

            spr.startPoint[0] = getPoint(requestParams.StartPoint);
            spr.endPoint[0] = getPoint(requestParams.EndPoint);

            //add constraints
            spr.constraint = createNetworkConstraints(requestParams.NetworkConstraints);

            //add link cost calculator
            spr.linkCostCalculator = createLinkCostCalculator(requestParams.LinkCostCalculator);

            //add requested information
            setupSubPathRequestParam(spr.subPathRequestParameter, requestParams);

            //Transform the current request object representation to XML
            string xmlRequest = XmlManager.Instance.convertObjectToXml(requestObject, requestObject.GetType());
            string xmlResponse = RequestAnalysis(xmlRequest);
            NetworkAnalysisResult nar = createNetworkAnalysisResult(requestObject,xmlRequest,xmlResponse);
            return nar;
        }

        public NetworkAnalysisResult PerformNearestNeighborsAnalysis(NetworkAnalysisRequestParams requestParams)
        {
            //Create an xml request object representation using a template
            NetworkAnalysisRequestType requestObject = LoadRequestFromTemplate(NetworkAnalysisType.NearestNeightbors);
            NearestNeighborsRequestType nnr = (NearestNeighborsRequestType)requestObject.Item;
            nnr.startPoint = getPoint(requestParams.StartPoint);
            nnr.noOfNeighbors = requestParams.NumberOfNeighbors;
            setupSubPathRequestParam(nnr.subPathRequestParameter, requestParams);
            //Transform the current request object representation to XML
            string xmlRequest = XmlManager.Instance.convertObjectToXml(requestObject, requestObject.GetType());
            string xmlResponse = RequestAnalysis(xmlRequest);
            NetworkAnalysisResult nar = createNetworkAnalysisResult(requestObject, xmlRequest, xmlResponse);
            return nar;
        }

        public NetworkAnalysisResult PerformWithinCostAnalysis(NetworkAnalysisRequestParams requestParams)
        {
            NetworkAnalysisRequestType requestObject = LoadRequestFromTemplate(NetworkAnalysisType.WithinCost);
            WithinCostRequestType wcr = (WithinCostRequestType)requestObject.Item;
            wcr.startPoint = getPoint(requestParams.StartPoint);
            wcr.cost = requestParams.WithinCost;
            setupSubPathRequestParam(wcr.subPathRequestParameter, requestParams);
            //Transform the current request object representation to XML
            string xmlRequest = XmlManager.Instance.convertObjectToXml(requestObject, requestObject.GetType());
            string xmlResponse = RequestAnalysis(xmlRequest);
            NetworkAnalysisResult nar = createNetworkAnalysisResult(requestObject, xmlRequest, xmlResponse);
            return nar;
        }

        public NetworkAnalysisResult PerformTspAnalysis(NetworkAnalysisRequestParams requestParams)
        {
            NetworkAnalysisRequestType requestObject = LoadRequestFromTemplate(NetworkAnalysisType.Tsp);
            tspRequestType tspr = (tspRequestType)requestObject.Item;
            tspr.tspPoint = new PointOnNetType[requestParams.TspPoints.Length];
            for (int i = 0; i < requestParams.TspPoints.Length; i++)
            {
                tspr.tspPoint[i] = getPoint(requestParams.TspPoints[i]);
            }
            tspr.tourFlag = requestParams.TspFlag.ToString();
            setupSubPathRequestParam(tspr.tspPathRequestParameter.subPathRequestParameter, requestParams);
            //Transform the current request object representation to XML
            string xmlRequest = XmlManager.Instance.convertObjectToXml(requestObject, requestObject.GetType());
            string xmlResponse = RequestAnalysis(xmlRequest);
            NetworkAnalysisResult nar = createNetworkAnalysisResult(requestObject, xmlRequest, xmlResponse);
            return nar;
        }

        private JavaObjectType[] createNetworkConstraints(string[] networkConstraints)
        {
            JavaObjectType[] constraints = new JavaObjectType[networkConstraints.Length];
            for (int i = 0; i < networkConstraints.Length; i++)
            {
                JavaObjectType constraint = new JavaObjectType();
                constraint.className = networkConstraints[i];
                constraints[i] = constraint;
            }
            return constraints;
        }

        private JavaObjectType[] createLinkCostCalculator(string linkCostCalculator)
        {
            JavaObjectType[] lcc = null;
            if (linkCostCalculator != null)
            {
                JavaObjectType jot = new JavaObjectType();
                jot.className = linkCostCalculator;
                lcc = new JavaObjectType[] { jot };
            }
            return lcc;
        }

        private void setupSubPathRequestParam(SubPathRequestParameterType subPath, NetworkAnalysisRequestParams param)
        {
            if (!param.RequestGeometryInfo)
            {
                subPath.geometry = false;
                subPath.pathRequestParameter.geometry = false;
            }

            if (!param.RequestDetailedPathInfo)
            {
                subPath.pathRequestParameter.linksRequestParameter.Item = true;
                subPath.pathRequestParameter.nodesRequestParameter.Items = new object[] { true };
            }
            else if (!param.RequestGeometryInfo)
            {
                ((LinkRequestParameterType)subPath.pathRequestParameter.linksRequestParameter.Item).geometry = false;
                ((NodeRequestParameterType)subPath.pathRequestParameter.nodesRequestParameter.Items[0]).geometry = false;
            }
        }

        private NetworkAnalysisResult createNetworkAnalysisResult(NetworkAnalysisRequestType requestObject, string requestXml, string responseXml)
        {
            NetworkAnalysisResult nar = new NetworkAnalysisResult();
            nar.RequestObject = requestObject;
            nar.RequestXml = requestXml;
            nar.ResponseXml = responseXml;
            if (responseXml != null && responseXml.Trim().Length > 0)
            {
                nar.ResponseObject = (NetworkAnalysisResponseType)XmlManager.Instance.convertXmlToObject(typeof(NetworkAnalysisResponseType), responseXml);
            }
            else 
            {
                throw new Exception("The server did not replay a valid response. Server response:["+responseXml+"]");
            }
            return nar;
        }

        private PointOnNetType getPoint(string point)
        {
            PointOnNetType pointOnNet = new PointOnNetType();
            point = point.Trim();
            int separatorIndex = point.IndexOf("@"); 
            if (separatorIndex < 0)
            {
                long nodeId = 0;
                try
                {
                    nodeId = long.Parse(point);
                }
                catch(Exception ex)
                {
                    throw new NetworkAnalysisRequestException("Invalid point format: ["+point+"]", ErrorCategoryType.RequestParams, ex);
                }
                pointOnNet.ItemsElementName = new ItemsChoiceType[] { ItemsChoiceType.nodeID };
                pointOnNet.Items = new object[]{nodeId};
            }
            else
            {
                long linkId = 0;
                double percentage = 0.0;
                try
                {
                    linkId = long.Parse(point.Substring(0,separatorIndex));
                    percentage = double.Parse(point.Substring(separatorIndex+1, point.Length-separatorIndex));
                }
                catch (Exception ex)
                {
                    throw new NetworkAnalysisRequestException("Invalid point format: [" + point + "]", ErrorCategoryType.RequestParams, ex);
                }
                pointOnNet.ItemsElementName = new ItemsChoiceType[] { ItemsChoiceType.linkID, ItemsChoiceType.percentage};
                pointOnNet.Items = new object[] { linkId, percentage };
            }
            return pointOnNet;
        }


        protected string RequestAnalysis(string xmlRequest)
        {
            NetworkAnalysisHttpClient client = new NetworkAnalysisHttpClient();
            client.TargetUrl = networkAnalysisServiceUrl;
            string xmlResponse = client.requestNetworkAnalysis(xmlRequest);
            return xmlResponse;
        }
    }
}
