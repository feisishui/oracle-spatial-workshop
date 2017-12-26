/* $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/ExcludeHighwaysConstraint.java /main/1 2012/03/05 05:46:15 begeorge Exp $ */

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
 *  @version $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/ExcludeHighwaysConstraint.java /main/1 2012/03/05 05:46:15 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */
package polygons;
import oracle.spatial.network.UserDataMetadata;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.NetworkAnalyst;

/**
 * Class that implements LODNetworkConstraint. No high ways are allowed on the path.
 */
public class ExcludeHighwaysConstraint implements LODNetworkConstraint
{
  private static int[] defaultUserDataCategories={UserDataMetadata.DEFAULT_USER_DATA_CATEGORY};
  public  ExcludeHighwaysConstraint(){}

  public boolean isSatisfied(LODAnalysisInfo info)
  {
    LogicalLink link = info.getNextLink();
    if (link==null || link.getLevel() == 1 )
      return true;
    else
      return false;
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
    return defaultUserDataCategories;
  }

  public void reset()
  {
  }

  public void setNetworkAnalyst(NetworkAnalyst analyst)
  {
  }
}


