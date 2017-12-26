using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Oracle.Spatial.XmlNdmAnalysis
{
    public class NetworkAnalysisRequestParams
    {
        public string StartPoint { get; set; }

        public string EndPoint { get; set; }

        public int NumberOfNeighbors{ get; set; }

        public double WithinCost { get; set; }

        public string[] TspPoints { get; set; }

        public TspFlag TspFlag { get; set; }

        public string[] NetworkConstraints { get; set; }

        public string LinkCostCalculator { get; set; }

        public bool RequestGeometryInfo { get; set; }

        public bool RequestDetailedPathInfo { get; set; }
    }
}
