using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Oracle.Spatial.XmlNdmAnalysis;
using System.Collections;
using System.IO;

namespace NDMDemo
{
    public partial class NDMXmlForm : Form
    {
          
        private delegate string GetStringRepresentation(object obj);

        //The last network analysis result. Used to show the XML for the request and response
        private NetworkAnalysisResult lastNaResult = null;

        private ContentViewerForm contentViewer = null;

        //The object used to perform the network analysis
        private NetworkAnalysisPerformer naPerformer = null;

        private string tmpFilePath = null;

        public NDMXmlForm()
        {

            InitializeComponent();
            naPerformer = new NetworkAnalysisPerformer(Settings.Default.spatialWsUrl, Settings.Default.templatesDir, Settings.Default.targetNetwork);
            setupControls();
        }

        #region utility functions
        private void setupControls()
        {
            //Add analysis options
            IDictionary<NetworkAnalysisType, string> naOptions = new Dictionary<NetworkAnalysisType, string>();
            naOptions[NetworkAnalysisType.ShortestPath] = "Shortest Path";
            naOptions[NetworkAnalysisType.NearestNeightbors] = "Nearest Neightbors";
            naOptions[NetworkAnalysisType.Tsp] = "Traveler Sales Person Problem";
            naOptions[NetworkAnalysisType.WithinCost] = "Within Cost";
            this.networkAnalysisControl.DataSource = new BindingSource(naOptions, null);
            this.networkAnalysisControl.ValueMember = "Key";
            this.networkAnalysisControl.DisplayMember = "Value";
            this.networkAnalysisControl.SelectedIndexChanged += new System.EventHandler(this.networkAnalysisControl_SelectedIndexChanged);
            //select default link cost calculator
            this.linkCostCalculatorControl.SelectedIndex = 0;
            //Add tsp flags
            IDictionary<TspFlag, string> tspFlags = new Dictionary<TspFlag, string>();
            tspFlags[TspFlag.CLOSED] = "Closed";
            tspFlags[TspFlag.OPEN] = "Open";
            tspFlags[TspFlag.OPEN_FIXED_END] = "Open With Fixed End Point";
            tspFlags[TspFlag.OPEN_FIXED_START] = "Open With Fixed Start Point";
            tspFlags[TspFlag.OPEN_FIXED_START_END] = "Open With Fixed Start And End Point";
            this.tspFlagControl.DataSource = new BindingSource(tspFlags, null);
            this.tspFlagControl.ValueMember = "Key";
            this.tspFlagControl.DisplayMember = "Value";
            //Hide options for other analysis types
            this.nearestNeighborsPanel.Visible = false;
            this.withinCostPanel.Visible = false;
            this.tspPanel.Visible = false;

        }

        private string[] getSelectedNetworkConstraints()
        {
            ListBox.SelectedObjectCollection selectedItems = this.networkConstraintControl.SelectedItems;
            string[] networkConstraints = new string[selectedItems.Count];
            for (int i = 0; i < networkConstraints.Length; i++)
            {
                networkConstraints[i] = (string)selectedItems[i];
            }
            return networkConstraints;
        }

        private string getSelectedLinkCostCalculator()
        {
            return this.linkCostCalculatorControl.SelectedIndex > 0 ? (string)this.linkCostCalculatorControl.SelectedItem : null;
        }

        private string linkTypeToString(object obj)
        {
            string str = null;
            if (obj!=null && obj is LinkType)
            {
                LinkType link = (LinkType) obj;
                str = ""+link.id;
            }
            return str;
        }

        private string nodeTypeToString(object obj)
        {
            string str = null;
            if (obj != null && obj is NodeType)
            {
                NodeType node = (NodeType)obj;
                str = "" + node.id;
            }
            return str;
        }

        private string arrayToString<T>(T[] anArray, GetStringRepresentation stringRepresentation = null)
        {
            if (anArray == null)
            {
                return null;
            }
            StringBuilder str = new StringBuilder("[");
            bool firstItem = true;
            foreach (T item in anArray) 
            {
                str.Append(!firstItem ? ", " :  "");
                if (stringRepresentation != null)
                {
                    str.Append(stringRepresentation(item));
                }
                else
                {
                    str.Append(item != null ? item.ToString() : "null");
                }
                firstItem = false;
            }
            str.Append("]");
            return str.ToString();
        }

        private void displayXml(string xml)
        {
            //Create a temporary file with the generated request or response XML
            createXmlTmpFile(xml);
            Uri fileUri = new Uri("file://" + this.tmpFilePath.Replace("\\", "/"));
            //Create a browser window to show the xml temp file
            if (this.contentViewer == null)
            {
                this.contentViewer = new ContentViewerForm();
            }
            this.contentViewer.ContentUri = fileUri;
            this.contentViewer.ShowDialog();
        }

        private void createXmlTmpFile(string xml)
        {
            if (this.tmpFilePath == null)
            {
                this.tmpFilePath = Path.GetTempPath() + "tmp.xml";
            }
            Stream stream = new FileStream(tmpFilePath, FileMode.Create);
            byte[] xmlBuffer = Encoding.UTF8.GetBytes(xml);
            stream.Write(xmlBuffer, 0, xmlBuffer.Length);
            stream.Close();
        }

        private void removeXmlTmpFile()
        {
            if (File.Exists(this.tmpFilePath))
            {
                try
                {
                    File.Delete(this.tmpFilePath);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("The file ["+this.tmpFilePath+"] could not be removed", ex);
                }
            }
        }
        #endregion

        #region events
        private void button1_Click(object sender, EventArgs e)
        {
            this.lastNaResult = null;
            this.outputControl.Text = "";
            this.requestXmlLink.Enabled = false;
            this.responseXmlLink.Enabled = false;
            NetworkAnalysisType analysisType = (NetworkAnalysisType)this.networkAnalysisControl.SelectedValue;
            string analysisTypeText = ((KeyValuePair<NetworkAnalysisType, string>)this.networkAnalysisControl.SelectedItem).Value;
            this.outputControl.Text = "Performing analysis: " + analysisTypeText;
            this.outputControl.Refresh();
            ((Button)sender).Enabled = false;
            try
            {
                switch (analysisType)
                {
                    case NetworkAnalysisType.ShortestPath:
                        PerformShortestPathAnalysis();
                        break;
                    case NetworkAnalysisType.NearestNeightbors:
                        PerformNearestNeighbors();
                        break;
                    case NetworkAnalysisType.Tsp:
                        PerformTspAnalysis();
                        break;
                    case NetworkAnalysisType.WithinCost:
                        PerformWithinCostAnalysis();
                        break;
                    case NetworkAnalysisType.KShortestPaths:
                        break;
                }
            }
            catch (NetworkAnalysisRequestException ex)
            {
                if (ex.ErrorCategory == ErrorCategoryType.RequestParams)
                {
                    MessageBox.Show(ex.Message);
                }
            }
            if (lastNaResult != null)
            {
                this.requestXmlLink.Enabled = true;
                this.responseXmlLink.Enabled = true;
            }
            ((Button)sender).Enabled = true;
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            if(lastNaResult!=null && lastNaResult.RequestXml!=null)
            {
                displayXml(lastNaResult.RequestXml);
            } 
        }

        private void linkLabel2_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            if (lastNaResult != null && lastNaResult.ResponseXml!=null)
            {
                displayXml(lastNaResult.ResponseXml);
            }
        }

        private void networkAnalysisControl_SelectedIndexChanged(object sender, EventArgs e)
        {
            NetworkAnalysisType analysisType = (NetworkAnalysisType)this.networkAnalysisControl.SelectedValue;

            //reset control values
            //this.startPointControl.Text = string.Empty;
            //this.endPointControl.Text = string.Empty;
            //this.costControl.Text = string.Empty;
            //this.noOfNodesControl.Text = string.Empty;
            //this.tspPointsControl.Text = string.Empty;
            this.networkConstraintControl.ClearSelected();
            this.linkCostCalculatorControl.SelectedIndex = 0;
            this.reqDetailedInfoCkb.Checked = false;
            this.reqGeomInfoCkb.Checked = false;
            this.tspFlagControl.SelectedIndex = 0;
            this.outputControl.Text = string.Empty;

            //disable and hide all controls
            this.nearestNeighborsPanel.Visible = false;
            this.withinCostPanel.Visible = false;
            this.nearestNeighborsPanel.Visible = false;
            this.networkConstraintControl.Enabled = false;
            this.linkCostCalculatorControl.Enabled = false;
            this.tspPanel.Visible = false;
            switch (analysisType)
            {
                case NetworkAnalysisType.ShortestPath:
                    this.networkConstraintControl.Enabled = true;
                    this.linkCostCalculatorControl.Enabled = true;
                    break;
                case NetworkAnalysisType.NearestNeightbors:
                    this.nearestNeighborsPanel.Visible = true;
                    break;
                case NetworkAnalysisType.Tsp:
                    this.tspPanel.Visible = true;
                    break;
                case NetworkAnalysisType.WithinCost:
                    this.withinCostPanel.Visible = true;
                    break;
                case NetworkAnalysisType.KShortestPaths:
                    break;
            }
        }
        #endregion

        #region network analysis requests

        protected void PerformShortestPathAnalysis()
        {
            //Gather user input from GUI controls:
            //start and end point inputs
            NetworkAnalysisRequestParams requestParams = new NetworkAnalysisRequestParams();
            requestParams.StartPoint = this.startPointControl.Text;
            requestParams.EndPoint = this.endPointControl.Text;
            //network constraints
            requestParams.NetworkConstraints = getSelectedNetworkConstraints();
            //Link cost calculator
            requestParams.LinkCostCalculator = getSelectedLinkCostCalculator();
            //information detail requested
            requestParams.RequestGeometryInfo = this.reqGeomInfoCkb.Checked;
            requestParams.RequestDetailedPathInfo = this.reqDetailedInfoCkb.Checked;

            //Display messages
            this.outputControl.AppendText("\r\n\t start point:[" + requestParams.StartPoint + "], end point:[" + requestParams.EndPoint + "]");
            this.outputControl.AppendText("\r\n\t Network constrainst " + arrayToString(requestParams.NetworkConstraints) + "");
            this.outputControl.AppendText("\r\n\t Link cost calculator [" + this.linkCostCalculatorControl.SelectedItem + "]\r\n");
            this.outputControl.AppendText("\r\nSending request.....");
            this.outputControl.Refresh();
            try
            {
                //send request and receive a response
                NetworkAnalysisResult naResult = naPerformer.PerformShortestPathAnalysis(requestParams);

                NetworkAnalysisResponseType nares = naResult.ResponseObject;
                ShortestPathResponseType spres = (ShortestPathResponseType)nares.Item;

                this.outputControl.AppendText("\r\nAnalysis Results::");
                this.outputControl.AppendText("\r\n\tCost:" + spres.subPathResponse.costs);
                this.outputControl.AppendText("\r\n\tGeometry information included:" + (spres.subPathResponse.geometry != null));
                this.outputControl.AppendText("\r\n\tLink information included:" + (spres.subPathResponse.pathResponse.linkResponse != null));
                this.outputControl.AppendText("\r\n\tNode information included:" + (spres.subPathResponse.pathResponse.nodeResponse != null));
                this.outputControl.AppendText("\r\n\tNumber of links:" + spres.subPathResponse.pathResponse.noOfLinks);
                if (spres.subPathResponse.pathResponse.linkResponse != null && spres.subPathResponse.pathResponse.nodeResponse != null)
                {
                    this.outputControl.AppendText("\r\n\tLink ID's:[" +
                        arrayToString(spres.subPathResponse.pathResponse.linkResponse, linkTypeToString) + "]");

                    this.outputControl.AppendText("\r\n\tNumber of nodes:" + spres.subPathResponse.pathResponse.nodeResponse.Length);

                    this.outputControl.AppendText("\r\n\tNode ID's:[" +
                        arrayToString(spres.subPathResponse.pathResponse.nodeResponse, nodeTypeToString) + "]");
                }
                this.lastNaResult = naResult;
            }
            catch (Exception ex)
            {
                this.outputControl.AppendText("\r\nThere was a problem performing the analysis:" + ex.Message);
            }
        }

        protected void PerformNearestNeighbors()
        {
            NetworkAnalysisRequestParams requestParams = new NetworkAnalysisRequestParams();
            //Gather user input from GUI controls:
            //start and end point inputs
            requestParams.StartPoint = this.startPointControl.Text;
            try
            {
                requestParams.NumberOfNeighbors = int.Parse(this.noOfNodesControl.Text);
            }
            catch
            {
                throw new NetworkAnalysisRequestException("Invalid number format for Number of Neighbors field", ErrorCategoryType.RequestParams);
            }
            //information detail requested
            requestParams.RequestGeometryInfo = this.reqGeomInfoCkb.Checked;
            requestParams.RequestDetailedPathInfo = this.reqDetailedInfoCkb.Checked;

            //Display messages
            this.outputControl.AppendText("\r\n\t start point:[" + requestParams.StartPoint + "], Number of neighbors:[" + requestParams.NumberOfNeighbors + "]");
            this.outputControl.AppendText("\r\n\t Network constrainst [" + arrayToString(requestParams.NetworkConstraints) + "]");
            this.outputControl.AppendText("\r\n\t Link cost calculator [" + this.linkCostCalculatorControl.SelectedItem + "]");
            this.outputControl.AppendText("\r\nSending request.....");
            this.outputControl.Refresh();

            try
            {
                //send request and receive a response
                NetworkAnalysisResult naResult = naPerformer.PerformNearestNeighborsAnalysis(requestParams);

                NetworkAnalysisResponseType nares = naResult.ResponseObject;
                NearestNeighborsResponseType nnres = (NearestNeighborsResponseType)nares.Item;
                this.outputControl.AppendText("\r\nAnalysis Results::");
                this.outputControl.AppendText("\r\n\tNumber of paths:" + nnres.Items.Length);
                foreach (object item in nnres.Items)
                {
                    SubPathResponseType subPath = (SubPathResponseType)item;
                    this.outputControl.AppendText("\r\n\tPath cost:[" + subPath.costs + "] End node:[" + subPath.pathResponse.endNodeID + "]");
                }

                this.lastNaResult = naResult;
            }
            catch (Exception ex)
            {
                this.outputControl.AppendText("\r\nThere was a problem performing the analysis:" + ex.Message);
            }
        }

        protected void PerformWithinCostAnalysis()
        {
            NetworkAnalysisRequestParams requestParams = new NetworkAnalysisRequestParams();
            //Gather user input from GUI controls:
            //start and end point inputs
            requestParams.StartPoint = this.startPointControl.Text;
            try
            {
                requestParams.WithinCost = double.Parse(this.costControl.Text);
            }
            catch
            {
                throw new NetworkAnalysisRequestException("Invalid number format for Cost field", ErrorCategoryType.RequestParams);
            }
            //information detail requested
            requestParams.RequestGeometryInfo = this.reqGeomInfoCkb.Checked;
            requestParams.RequestDetailedPathInfo = this.reqDetailedInfoCkb.Checked;

            //Display messages
            this.outputControl.AppendText("\r\n\t start point:[" + requestParams.StartPoint + "], Cost:[" + requestParams.WithinCost + "]");
            this.outputControl.AppendText("\r\nSending request.....");
            this.outputControl.Refresh();
            try
            {
                //send request and receive a response
                NetworkAnalysisResult naResult = naPerformer.PerformWithinCostAnalysis(requestParams);
                this.lastNaResult = naResult;
                NetworkAnalysisResponseType nares = naResult.ResponseObject;
                WithinCostResponseType wcres = (WithinCostResponseType)nares.Item;
                this.outputControl.AppendText("\r\nAnalysis Results::");
                if (wcres != null && wcres.Items != null)
                {
                    this.outputControl.AppendText("\r\n\tNumber of paths:" + wcres.Items.Length);
                    foreach (object item in wcres.Items)
                    {
                        SubPathResponseType subPath = (SubPathResponseType)item;
                        this.outputControl.AppendText("\r\n\tPath cost:[" + subPath.costs + "] End node:[" + subPath.pathResponse.endNodeID + "]");
                    }
                }
                else
                {
                    this.outputControl.AppendText("\r\n\tNo nodes were found within the specified cost");
                }
            }
            catch (NetworkAnalysisRequestException ex)
            {
                throw ex;
            }
            catch (Exception ex)
            {
                this.outputControl.AppendText("\r\nThere was a problem performing the analysis:" + ex.Message);

            }
        }

        public void PerformTspAnalysis()
        {
            NetworkAnalysisRequestParams requestParams = new NetworkAnalysisRequestParams();
            //Gather user input from GUI controls:
            requestParams.TspPoints = this.tspPointsControl.Text.Trim().Split(' ');

            requestParams.TspFlag = (TspFlag)this.tspFlagControl.SelectedValue;
            //information detail requested
            requestParams.RequestGeometryInfo = this.reqGeomInfoCkb.Checked;
            requestParams.RequestDetailedPathInfo = this.reqDetailedInfoCkb.Checked;

            //Display messages
            this.outputControl.AppendText("\r\n\t TSP Points: [" + this.tspPointsControl.Text.Trim() + "]");
            this.outputControl.AppendText("\r\nSending request.....");
            this.outputControl.Refresh();
            try
            {
                //send request and receive a response
                NetworkAnalysisResult naResult = naPerformer.PerformTspAnalysis(requestParams);

                NetworkAnalysisResponseType nares = naResult.ResponseObject;
                TspResponseType tspres = (TspResponseType)nares.Item;
                this.outputControl.AppendText("\r\nAnalysis Results::");
                this.outputControl.AppendText("\r\n\tTSP Points Order:");
                string[] subPathIndexes = tspres.tspOrder.Trim().Split(' ');
                foreach (string index in subPathIndexes)
                {
                    this.outputControl.AppendText(" " + requestParams.TspPoints[int.Parse(index)]);
                }
                this.outputControl.AppendText("\r\n\tPaths:" + tspres.subPathResponse.Length);
                foreach (SubPathResponseType subPath in tspres.subPathResponse)
                {
                    this.outputControl.AppendText("\r\n\t\t" + subPath.pathResponse.startNodeID + "->" + subPath.pathResponse.endNodeID);
                    this.outputControl.AppendText("\r\n\t\t\tCosts:" + subPath.pathResponse.costs);
                }
                this.outputControl.AppendText("\r\n\tCumulative costs to reach each point:");
                this.outputControl.AppendText("\r\n\t\t" + requestParams.TspPoints[0] + " costs 0.0");
                double cumaltiveCost = 0.0;
                foreach (SubPathResponseType subPath in tspres.subPathResponse)
                {
                    cumaltiveCost += double.Parse(subPath.costs);
                    this.outputControl.AppendText("\r\n\t\t" + subPath.pathResponse.endNodeID + " costs " + cumaltiveCost);
                }

                this.lastNaResult = naResult;
            }
            catch (Exception ex)
            {
                this.outputControl.AppendText("\r\nThere was a problem performing the analysis:" + ex.Message);
            }
        }

        #endregion
    }
}
