/* $Header: sdo/demo/network/examples/java/src/lod/persistent_network_buffers/LinkTravelTimeCalculator.java /main/1 2012/05/24 07:15:54 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    04/16/12 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/persistent_network_buffers/LinkTravelTimeCalculator.java /main/1 2012/05/24 07:15:54 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */
package nbuffer;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.UserDataMetadata;
import oracle.spatial.router.ndm.RouterPartitionBlobTranslator11gR2;
import oracle.spatial.network.lod.LinkCostCalculator;
public class LinkTravelTimeCalculator implements LinkCostCalculator
{
      int [] defaultUserDataCategories = {UserDataMetadata.DEFAULT_USER_DATA_CATEGORY};

      public LinkTravelTimeCalculator () {
      }

      public double getLinkCost(LODAnalysisInfo analysisInfo)
      {
        LogicalLink link = analysisInfo.getNextLink();

       // speed in meters/second
       double speed = ((Double)link.getUserData(0).get
                      (RouterPartitionBlobTranslator11gR2.USER_DATA_INDEX_SPEED_LIMIT)).doubleValue();
       return (link.getCost()/speed);         // travel time in seconds
      }

      public int[] getUserDataCategories()
      {
        return defaultUserDataCategories;
      }
}
