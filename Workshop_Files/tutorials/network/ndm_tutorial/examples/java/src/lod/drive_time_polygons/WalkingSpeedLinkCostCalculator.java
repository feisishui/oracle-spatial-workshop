
/* $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/WalkingSpeedLinkCostCalculator.java /main/1 2012/03/05 05:46:15 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    02/24/12 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/WalkingSpeedLinkCostCalculator.java /main/1 2012/03/05 05:46:15 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */
package polygons;

 import java.text.SimpleDateFormat;
 import java.util.HashMap;
 import java.util.Map;
 import java.util.Date;
 import java.util.Calendar;
 import java.util.Locale;
 import java.util.TimeZone;
 import oracle.spatial.network.lod.UserData;
 import oracle.spatial.network.lod.LODAnalysisInfo;
 import oracle.spatial.network.lod.LinkCostCalculator;
 import oracle.spatial.network.lod.LogicalLink;
 import oracle.spatial.network.UserDataMetadata;
 import oracle.spatial.router.ndm.RouterPartitionBlobTranslator11gR2;
import oracle.spatial.network.lod.LinkCostCalculator;

public class WalkingSpeedLinkCostCalculator implements LinkCostCalculator {
    private double walkingSpeed;
    private static int[] defaultUserDataCategories={UserDataMetadata.DEFAULT_USER_DATA_CATEGORY};
    public WalkingSpeedLinkCostCalculator() {
        
    }
    
    public WalkingSpeedLinkCostCalculator(double walkingSpeed) {
        this.walkingSpeed = walkingSpeed;
    }
    
    public double getLinkCost(LODAnalysisInfo analysisInfo) {
       LogicalLink link = analysisInfo.getNextLink();
       double linkLength = link.getCost();
       
       return (linkLength/walkingSpeed);
    }
    
    public int[] getUserDataCategories() {
        return defaultUserDataCategories;
    }  
    
}

