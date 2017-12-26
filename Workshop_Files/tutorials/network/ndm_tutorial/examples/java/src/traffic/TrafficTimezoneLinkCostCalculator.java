/* $Header: sdo/demo/network/examples/java/src/traffic/TrafficTimezoneLinkCostCalculator.java /main/3 2012/03/22 05:42:10 begeorge Exp $ */

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
    begeorge    02/20/12 - Modify to accomodate new navteq schema for traffic patterns
    begeorge    10/25/10 - Modify to accomodate truncation of speed series in user data 
    begeorge    10/21/10 - Add a check to see whether traffic user data category exists
    begeorge    09/21/10 - Add interface to find traffic pattern index
    begeorge    08/25/10 - Enhance to handle traffic pattern variation with day of week
    begeorge    03/15/10 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/traffic/TrafficTimezoneLinkCostCalculator.java /main/3 2012/03/22 05:42:10 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */
package ndmtraffic;

import java.text.DateFormat;
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
import oracle.spatial.router.ndm.RouterPartitionBlobTranslator11gR2;
import oracle.spatial.network.apps.traffic.TemporalUserDataIO;
import oracle.spatial.network.apps.traffic.TrafficTimezoneUserDataIO;

/**
 *  @version $Header: sdo/demo/network/examples/java/src/traffic/TrafficTimezoneLinkCostCalculator.java /main/3 2012/03/22 05:42:10 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */
public class TrafficTimezoneLinkCostCalculator implements LinkCostCalculator {

private static final int USER_DATA_DEFAULT_CATEGORY = 0;
private static final int USER_DATA_CATEGORY_TRUCKING = TemporalUserDataIO.USER_DATA_CATEGORY_TRUCKING;
private static final int USER_DATA_CATEGORY_TEMPORAL = 2;
private static final int USER_DATA_CATEGORY_FEATURE = 3;
private static final int USER_DATA_CATEGORY_TIMEZONE = 4;
private static final int[] userDataCategories = {0,1,2,3,4};

// Since traffic patterns are currently not available for holidays, 
// in the current example, the holiday_index is set to 4, 
// which corresponds to Sunday patterns

private static final String [] holidays = {"1 January 2010", "31 May 2010", "4 July 2010",
                          "6 September 2010", "25 November 2010", "26 November 2010",
                          "25 December 2010"};
private static final int HOLIDAY_INDEX = 4;
private Date startTime;
private int numIntervals;
private int startIndex;
private int endIndex;
private TimeZone est = TimeZone.getTimeZone("US/Eastern");
    public TrafficTimezoneLinkCostCalculator()   {
        
    }
    public TrafficTimezoneLinkCostCalculator(String startTimeStr, int numIntervals) {
        try {
           Date startTime = null;
           SimpleDateFormat dFormat = new SimpleDateFormat("dd MMM yyyy hh:mm a z");
            if (validateDateWithTZ(startTimeStr)) {
                startTime = dFormat.parse(startTimeStr);
            }
            else    {
                String modifiedInput = startTimeStr+" EST";
                startTime = dFormat.parse(modifiedInput);
            }
           
           this.startTime = startTime;
           this.startIndex = 1;
           this.endIndex = numIntervals;
           this.numIntervals = numIntervals;
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public TrafficTimezoneLinkCostCalculator(String startTimeStr, 
                                             String startOfPeriodStr, 
                                             String endOfPeriodStr,
                                             int numIntervals)   {
        try {
            Date startTime = null;
            SimpleDateFormat dFormat = new SimpleDateFormat("dd MMM yyyy hh:mm a z");
            if (validateDateWithTZ(startTimeStr)) {
                startTime = dFormat.parse(startTimeStr);
            }
            else    {
                String modifiedInput = startTimeStr+" EST";
                startTime = dFormat.parse(modifiedInput);
            }
            
            this.startTime = startTime; 
        
            //parameters related to trimmed time period
            SimpleDateFormat shortFormat = new SimpleDateFormat("hh:mm a");
            Date startOfPeriod = shortFormat.parse(startOfPeriodStr);
            Date endOfPeriod = shortFormat.parse(endOfPeriodStr);
            Calendar c = Calendar.getInstance(est,Locale.US);
            c.setTime(startOfPeriod);
            int hr = c.get(Calendar.HOUR_OF_DAY);
            int min = c.get(Calendar.MINUTE);
            int numIntervalsPerHour = numIntervals/24; 
            this.startIndex = hr*numIntervalsPerHour+
                              (min*numIntervalsPerHour)/60+1;
            c.setTime(endOfPeriod);
            hr = c.get(Calendar.HOUR_OF_DAY);
            min = c.get(Calendar.MINUTE);
            this.endIndex = hr*numIntervalsPerHour+
                            (min*numIntervalsPerHour)/60+1;
        
            this.numIntervals = numIntervals;
        }
        catch (Exception e) {
            System.out.println();
            e.printStackTrace();
        }
    }

    public double getLinkCost(LODAnalysisInfo analysisInfo)   {
    
        double linkTravelTime;
        
        LogicalLink link = analysisInfo.getNextLink();
        long linkId = link.getId();
        double linkLength = link.getCost();
        double linkSpeed = 1;
        int tzLink = 0;
        int tzDiff = 0;

        try{
           //Reads time zone of the link, if present
           int numUdata = link.getCategorizedUserData().getNumberOfCategories();
           System.out.println("Categories = "+numUdata); 
           if (link.getCategorizedUserData().getUserData(USER_DATA_CATEGORY_TIMEZONE) != null) 
               tzLink = (Integer) link.getCategorizedUserData().
                        getUserData(USER_DATA_CATEGORY_TIMEZONE).get(0);
            
           //Start time is always converted to EST  
           tzDiff = -tzLink;
        
           Calendar cCurrentTime= Calendar.getInstance(est,Locale.US); 
           cCurrentTime.setTime(startTime);
           
        // It is assumed that the cost of a link is the link length (as registered in metadata) 
        
            double [] currentPathCosts = analysisInfo.getCurrentCosts();

	// returns 0 if the end point is a point on link (and not a node)
        // In this case currentPathCosts is null
           if (currentPathCosts == null)
           {
               return 0;
           }

           double currentPathCost = currentPathCosts[0];
        
           linkSpeed = ((Double)link.getUserData(0).
                    get(RouterPartitionBlobTranslator11gR2.USER_DATA_INDEX_SPEED_LIMIT)).
                    doubleValue();
        
           //find hours,minutes,seconds in cost
           int numHoursInCurrentCost = ((int) currentPathCost)/(60*60);
           int numMinutesInCurrentCost = (((int) currentPathCost)/60) - (numHoursInCurrentCost*60);
           int numSecondsInCurrentCost = (int) (Math.round(currentPathCost - (numHoursInCurrentCost*60*60)
                                                            - (numMinutesInCurrentCost*60)));
            
           // Computing the current time, so that the appropriate link speed can be retrieved                                                
           // Also adjusting time for time zone changes by subtracting time difference
        
           cCurrentTime.add(Calendar.HOUR,numHoursInCurrentCost+tzDiff);
           cCurrentTime.add(Calendar.MINUTE,numMinutesInCurrentCost);
           cCurrentTime.add(Calendar.SECOND,numSecondsInCurrentCost);
           
           if (link.getCategorizedUserData().getUserData(USER_DATA_CATEGORY_TEMPORAL) != null) {
	      Map <Integer,Map> linkCostSeriesWithDay = (HashMap) link.getCategorizedUserData().
                                                        getUserData(USER_DATA_CATEGORY_TEMPORAL).
                                                        get(0);
/*
   Handles both schemas of navteq traffic pattern schema
   One has four patterns associated with a link corresponding to Mon-Thurs, Fri, Sat, Sun
   The other has seven patterns for a link, one for each day of the week
   The schema used is identified from the key values in the hashmap linkCostSeriesWithDay
   Values 1 - 4 indicate the first and values 1 - 7 indicate the second.
   trafficPatternIndex is then computed based on the schema used
*/ 
              int trafficPatternIndex = 1;
              if (linkCostSeriesWithDay.keySet().size() == 7)
                   trafficPatternIndex = findTrafficPatternIndex(cCurrentTime, 7);
              else
                   trafficPatternIndex = findTrafficPatternIndex(cCurrentTime, 4);

              Map <Integer,Float> linkCostSeries = new HashMap();
              if (linkCostSeriesWithDay != null) {
                 if (linkCostSeriesWithDay.containsKey(trafficPatternIndex)) {
                    linkCostSeries = linkCostSeriesWithDay.get(trafficPatternIndex);
                 }
                 else {
                    System.out.println("No linkcost series for day with index = "+trafficPatternIndex);
                 }   
             }
             int index = findTimeIndex(cCurrentTime);
             int initIndex = index;
            
             //Recomputing index for cases where link series has been truncated
             if (index >= startIndex || index <= endIndex) {
                 index = index-startIndex+1;
             }
             
             //check whether there is a link speed for the index
             // if not return the value at index 0 (default)
             // Unit of link speeed is meters/sec
            
             if (linkCostSeries.containsKey(index))    {
                 linkSpeed = linkCostSeries.get(index).doubleValue();
             }
             else  {
                //in meters per second
                linkSpeed = linkCostSeries.get(0).doubleValue();
            } 
           }
        
        }
        catch (Exception e) {
            System.out.println("Error while processing link "+linkId);
            e.printStackTrace();
        }
        // link travel time is computed in seconds
        linkTravelTime = linkLength/linkSpeed;
        return linkTravelTime;
    }

    public int[] getUserDataCategories()   {
        return userDataCategories;
    }

    private boolean validateDateWithoutTZ(String dateStr) {
        try {
            SimpleDateFormat dFormat = new SimpleDateFormat("dd MMM yyyy hh:mm a");
            Date dt = dFormat.parse(dateStr);
            return true;
        }
        catch (Exception e) {
            return false;
        }
    }
    
    private boolean validateDateWithTZ (String dateStr) {
        try {
            SimpleDateFormat dFormat = new SimpleDateFormat("dd MMM yyyy hh:mm a z");
            Date dt = dFormat.parse(dateStr);
            return true;
        }
        catch(Exception e) {
            return false;
        }
    }
    
    private Calendar getCalendarTime(Date time)   {
        TimeZone est = TimeZone.getTimeZone("US/Eastern");
        Calendar c = Calendar.getInstance(est,Locale.US);
        c.setTime(time);
        return c;
    }
    
    private int findTimeIndex(Calendar c)  {
        int hours = c.get(Calendar.HOUR_OF_DAY);
        int minutes = c.get(Calendar.MINUTE);
        int numIntervalsPerHour = numIntervals/24;
        
        return hours*numIntervalsPerHour + (minutes*numIntervalsPerHour)/60 + 1;
    }
    
    private int findDayOfWeek(Calendar c) {
        int dayOfWeek = c.get(Calendar.DAY_OF_WEEK);
        
        return dayOfWeek;
    }
    
    private int findMonth(Calendar c) {
        int month = c.get(Calendar.MONTH);
        return month;
    }
    
    private int findDayOfMonth(Calendar c) {
        int dayOfMonth = c.get(Calendar.DAY_OF_MONTH);
        return dayOfMonth;
    }
    
    private int findYear(Calendar c) {
        int year = c.get(Calendar.YEAR);
        return year;
    }
    
    private Date[] convertHolidaysToDates(String [] holidays) {
        SimpleDateFormat dFormat = new SimpleDateFormat("dd MMM yyyy");
        int size = holidays.length;
        Date [] holidayDates = new Date[size];
        try {
           for (int i=0; i<size; i++) {
              Date hDate = dFormat.parse(holidays[i]);
              holidayDates[i] = hDate;
           }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return holidayDates;
    }
    
    private boolean isDateAHoliday(Date [] holidayDates, Date dayMonthYear) {
        for (int i=0; i<holidayDates.length; i++) {
            if (holidayDates[i].equals(dayMonthYear)){
               return true;
            }
        }
        return false;
    }
    
    private int findTrafficPatternIndex(Calendar c, int numberOfPatterns) {
        SimpleDateFormat dayFormat = new SimpleDateFormat("dd MM yyyy");
        int dayOfWeek = findDayOfWeek(c);
        int dayIndex;
        int travelPatternIndex = 1;
        int sundayIndex = 1;

        if (numberOfPatterns == 7) {
           switch (dayOfWeek) {
               case 1: dayIndex = 1; 
                       break;
               case 2: dayIndex = 2;
                       break;
               case 3: dayIndex = 3;
                       break;
               case 4: dayIndex = 4;
                       break;
               case 5: dayIndex = 5;
                       break;
               case 6: dayIndex = 6;
                       break;
               case 7: dayIndex = 7;
                       break;
               default: dayIndex = 2;
                        break;
         }
        }
        else  {
           switch (dayOfWeek) {
               case 1: dayIndex = 4;
                       break;
               case 2: dayIndex = 1;
                       break;
               case 3: dayIndex = 1;
                       break;
               case 4: dayIndex = 1;
                       break;
               case 5: dayIndex = 1;
                       break;
               case 6: dayIndex = 2;
                       break;
               case 7: dayIndex = 3;
                       break;
               default: dayIndex = 2;
                        break;
           }
           sundayIndex = 4;
        }
        int month = findMonth(c);
        int dayOfMonth = findDayOfMonth(c);
        int year = findYear(c);
        String dayOfMonthStr = Integer.toString(dayOfMonth);
        String monthStr = Integer.toString(month+1);
        String yearStr = Integer.toString(year);
        
        String dateStr = dayOfMonthStr+" "+monthStr+" "+yearStr;
        try {
        Date dayMonthYear = dayFormat.parse(dateStr);
        Date [] holidayDates = convertHolidaysToDates(holidays);
        
        if (isDateAHoliday(holidayDates,dayMonthYear)) {
            travelPatternIndex = sundayIndex; 
        }
        else {
            travelPatternIndex = dayIndex; 
        }
        
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return travelPatternIndex;
    }
}
