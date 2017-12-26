package multimodalndm;

import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.XMLConfigurable;
import oracle.spatial.network.lod.util.XMLUtility;
import oracle.spatial.util.Logger;
import oracle.spatial.network.apps.multimodal.MultimodalUserDataIO;

import org.w3c.dom.Element;

public class TransferLinkLengthCalculator implements LinkCostCalculator, XMLConfigurable {
   private static final int[] userDataCategories = {
                              MultimodalUserDataIO.USER_DATA_CATEGORY_DEFAULT,
                              MultimodalUserDataIO.USER_DATA_CATEGORY_MULTIMODAL};
   public TransferLinkLengthCalculator() {
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
        System.out.println("Init");
    }

    public double getLinkCost(LODAnalysisInfo analysisInfo)   {
       double linkLength = 0;

       LogicalLink link = analysisInfo.getNextLink();
       double length = link.getCost();
       int linkType = (Integer)link.getCategorizedUserData().
                      getUserData(MultimodalUserDataIO.USER_DATA_CATEGORY_MULTIMODAL).
                      get(MultimodalUserDataIO.USER_DATA_INDEX_LINK_TYPE);
       switch (linkType) {
          case 0 :

          case 1 :

          case 2 :  linkLength = 0;
                    break;
          case 3  : linkLength = length;
                    break;
          default : linkLength = 0;
                    break;
      }
      return linkLength;
    }

    public int[] getUserDataCategories()   {
        return userDataCategories;
    }
}
