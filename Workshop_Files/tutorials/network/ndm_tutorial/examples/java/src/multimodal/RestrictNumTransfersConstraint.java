package multimodalndm;

import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.XMLConfigurable;
import oracle.spatial.network.lod.util.XMLUtility;
import oracle.spatial.util.Logger;

import org.w3c.dom.Element;

/**
 * Class that implements LODNetworkConstraint. 
 * Constraint restricts number of transfers.
*/

    public class RestrictNumTransfersConstraint implements LODNetworkConstraint, XMLConfigurable {
       private static final Logger logger = Logger.getLogger(
                                            RestrictNumTransfersConstraint.class.getName());
       private static int numTransfersLimit;
       private static final int[] userDataCategories = {0,1};
       public RestrictNumTransfersConstraint() {
       }
       
       public RestrictNumTransfersConstraint(int numTransfersLimit) {
          this.numTransfersLimit = numTransfersLimit;
       }
       
       public String getXMLSchema()
       {
          return null;
       }
    
       /**
       * Initializes the XML configurable object with the input parameter.
       * @param parameter an XML element containing the necessary information to
       * initialize the object.
       */
       public void init(Element parameter)
       {
          this.numTransfersLimit =
                     Integer.parseInt(XMLUtility.getFirstChildElementValue(
                                      parameter, null, "numTransfersLimit"));
          logger.debug("Number of transfers is "+numTransfersLimit);
       }
       
       public boolean isSatisfied(LODAnalysisInfo analysisInfo) {
         boolean isNumTransfersWithinLimit = true;
         double [] nextCosts = analysisInfo.getNextCosts();
         if (nextCosts[1] > numTransfersLimit) {
             isNumTransfersWithinLimit = false;
         }
         return isNumTransfersWithinLimit;
       }
       
       public int getNumberOfUserObjects()
       {
          return 0;
       }

       public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo info)
       {
          return false;
       }

       public boolean isNextNodePartiallyExpanded(LODAnalysisInfo info)
       {
          return false;
       }

       public int[] getUserDataCategories()
       {
          return userDataCategories;
       }

       public void reset()
       {
       }

       public void setNetworkAnalyst(NetworkAnalyst analyst)
       {
       }
}

