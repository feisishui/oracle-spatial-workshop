using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Oracle.Spatial.XmlNdmAnalysis
{
    public enum ErrorCategoryType { RequestParams, XmlRequest, XmlResponse, Network, General}
    public class NetworkAnalysisRequestException : Exception
    {

        private ErrorCategoryType errorCategory = ErrorCategoryType.General;

        public ErrorCategoryType ErrorCategory 
        {
            get
            {
                return errorCategory;
            }
        }

        public NetworkAnalysisRequestException(string msg) : base(msg) { }

        public NetworkAnalysisRequestException(string msg, ErrorCategoryType errorCategory) : base(msg) 
        {
            this.errorCategory = errorCategory;
        }

        public NetworkAnalysisRequestException(string msg, ErrorCategoryType errorCategory, Exception innerException)
            : base(msg, innerException) 
        {
            this.errorCategory = errorCategory;
        }


    }
}
