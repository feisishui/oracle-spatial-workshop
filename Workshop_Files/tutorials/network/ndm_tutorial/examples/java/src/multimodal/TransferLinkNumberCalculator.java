/* $Header: sdo/demo/network/examples/java/src/multimodal/TransferLinkNumberCalculator.java /main/1 2012/06/14 05:32:51 begeorge Exp $ */

/* Copyright (c) 2010, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    05/10/11 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/multimodal/TransferLinkNumberCalculator.java /main/1 2012/06/14 05:32:51 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
*/
package multimodalndm;

import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.XMLConfigurable;
import oracle.spatial.network.lod.util.XMLUtility;
import oracle.spatial.util.Logger;
import oracle.spatial.network.apps.multimodal.MultimodalUserDataIO;

import org.w3c.dom.Element;

public class TransferLinkNumberCalculator implements LinkCostCalculator, XMLConfigurable {
       private static final int[] userDataCategories = 
                                  {MultimodalUserDataIO.USER_DATA_CATEGORY_DEFAULT,
                                   MultimodalUserDataIO.USER_DATA_CATEGORY_MULTIMODAL};
       public TransferLinkNumberCalculator() {
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
          double transferLinkNum = 0;
              
          LogicalLink link = analysisInfo.getNextLink();
          int linkType = (Integer)link.getCategorizedUserData().
                          getUserData(MultimodalUserDataIO.USER_DATA_CATEGORY_MULTIMODAL).
                          get(MultimodalUserDataIO.USER_DATA_INDEX_LINK_TYPE);
          switch (linkType) {
              case 0 : 
                   
              case 1 : 
                   
              case 2 :  transferLinkNum = 0;
                        break;
              case 3  : transferLinkNum = 1;
                        break;
              default : transferLinkNum = 0;
                        break;       
          }
          return transferLinkNum;
       }
           
       public int[] getUserDataCategories()   {
          return userDataCategories;
       }
    } 
