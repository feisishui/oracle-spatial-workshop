
namespace Oracle.Spatial.XmlNdmAnalysis
{
    
    public enum NetworkAnalysisType
    { 
        ShortestPath, NearestNeightbors, WithinCost, KShortestPaths, Tsp

    };

    public enum TspFlag
    {
        CLOSED, OPEN, OPEN_FIXED_START, OPEN_FIXED_END, OPEN_FIXED_START_END
    }

 
}
