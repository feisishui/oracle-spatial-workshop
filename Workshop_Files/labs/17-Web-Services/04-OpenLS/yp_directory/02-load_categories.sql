/*

  Populate the business categories table

  The category ids and names correspond to the classification of Navteq POIs.
  The hierarchical structure is based on the distribution of the POIs into tables.

  Not all categories are used in the businesses we will load.

*/

-- Load top level categories
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10001, 'TOURISTIC', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10002, 'SHOP', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10003, 'RESTAURANT', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10004, 'TRANSPORTATION', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10005, 'HOTEL', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10006, 'BUSINESS', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10007, 'AUTO', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10008, 'CITY_CENTER', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10009, 'ACTIVITY', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10010, 'PUBLIC_FACILITY', 1, null);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (10011, 'SERVICE', 1, null);

-- Load other categories
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (2084, 'WINERY', 1, 10001);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (3578, 'ATM', 1, 10006);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (4013, 'TRAIN STATION', 1, 10004);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (4100, 'COMMUTER RAIL STATION', 1, 10004);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (4130, 'BUS STOP', 1, 10004);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (4170, 'BUS STATION', 1, 10004);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (4444, 'NAMED PLACE', 1, 10008);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (4482, 'FERRY TERMINAL', 1, 10004);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (4493, 'MARINA', 1, 10001);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (4580, 'PUBLIC SPORTS AIRPORT', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (4581, 'AIRPORT', 1, 10004);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (5000, 'BUSINESS FACILITY', 1, 10006);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (5400, 'GROCERY STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (5511, 'AUTO DEALERSHIPS', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (5512, 'AUTO DEALERSHIP-USED CARS', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (5540, 'PETROL/GASOLINE STATION', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (5571, 'MOTORCYCLE DEALERSHIP', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (5800, 'RESTAURANT', 1, 10003);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (5813, 'NIGHTLIFE', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (5999, 'HISTORICAL MONUMENT', 1, 10001);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (6000, 'BANK', 1, 10006);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (6512, 'SHOPPING', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7011, 'HOTEL', 1, 10005);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7012, 'SKI RESORT', 1, 10001);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7013, 'GUEST HOUSE', 1, 10005);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7389, 'TOURIST INFORMATION', 1, 10001);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7510, 'RENTAL CAR AGENCY', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7520, 'PARKING LOT', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7521, 'PARKING GARAGE/HOUSE', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7522, 'PARK AND RIDE', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7538, 'AUTO SERVICE AND MAINTENANCE', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7832, 'CINEMA', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7897, 'REST AREA', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7929, 'PERFORMING ARTS', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7933, 'BOWLING CENTRE', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7940, 'SPORTS COMPLEX', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7947, 'PARK/RECREATION AREA', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7985, 'CASINO', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7990, 'CONVENTION/EXHIBITION CENTRE', 1, 10006);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7992, 'GOLF COURSE', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7994, 'CIVIC/COMMUNITY CENTRE', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7996, 'AMUSEMENT PARK', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7997, 'SPORTS CENTRE', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7998, 'ICE SKATING RINK', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (7999, 'TOURIST ATTRACTION', 1, 10001);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (8060, 'HOSPITAL', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (8200, 'HIGHER EDUCATION', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (8211, 'SCHOOL', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (8231, 'LIBRARY', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (8410, 'MUSEUM', 1, 10001);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (8699, 'AUTOMOBILE CLUB', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9121, 'CITY HALL', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9211, 'COURT HOUSE', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9221, 'POLICE STATION', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9500, 'BUSINESS SERVICE', 1, 10006);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9592, 'HIGHWAY EXIT', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9991, 'INDUSTRIAL ZONE', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9501, 'OTHER COMMUNICATION', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9502, 'TELEPHONE SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9503, 'CLEANING AND LAUNDRY', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9504, 'HAIR AND BEAUTY', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9505, 'HEALTH CARE SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9506, 'MOVER', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9507, 'PHOTOGRAPHY', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9508, 'VIDEO AND GAME RENTAL', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9509, 'STORAGE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9510, 'TAILOR AND ALTERATION', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9511, 'TAX SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9512, 'REPAIR SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9513, 'RETIREMENT/NURSING HOME', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9514, 'SOCIAL SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9515, 'UTILITIES', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9516, 'WASTE AND SANITARY', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9517, 'CAMPING', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9518, 'AUTO PARTS', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9519, 'CAR WASH/DETAILING', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9520, 'LOCAL TRANSIT', 1, 10004);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9521, 'TRAVEL AGENT AND TICKETING', 1, 10004);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9522, 'TRUCK STOP/PLAZA', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9523, 'CHURCH', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9524, 'SYNAGOGUE', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9525, 'GOVERNMENT OFFICES', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9526, 'PRE-SCHOOL', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9527, 'FIRE DEPARTMENT', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9528, 'ROAD ASSISTANCE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9529, 'FUNERAL DIRECTOR', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9530, 'POST OFFICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9531, 'BANQUET HALL', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9532, 'BAR OR PUB', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9533, 'COCKTAIL LOUNGE', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9534, 'NIGHT CLUB', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9535, 'CONVENIENCE STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9536, 'SPECIALTY FOOD STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9537, 'CLOTHING STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9538, 'MEN''S APPAREL', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9539, 'SHOE STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9540, 'SPECIALTY CLOTHING STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9541, 'WOMEN''S APPAREL', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9542, 'CHECK CASHING SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9543, 'CURRENCY EXCHANGE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9544, 'MONEY TRANSFERRING SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9545, 'DEPARTMENT STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9546, 'DISCOUNT STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9547, 'OTHER GENERAL MERCHANDISE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9548, 'VARIETY STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9549, 'GARDEN CENTER', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9550, 'GLASS AND WINDOW', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9551, 'HARDWARE STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9552, 'HOME CENTER', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9553, 'LUMBER', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9554, 'OTHER HOUSE AND GARDEN', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9555, 'PAINT', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9556, 'ENTERTAINMENT ELECTRONICS', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9557, 'FLOOR AND CARPET', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9558, 'FURNITURE STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9559, 'MAJOR APPLIANCE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9560, 'HOME SPECIALITY STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9561, 'COMPUTER AND SOFTWARE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9562, 'FLOWERS AND JEWELRY', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9563, 'GIFT, ANTIQUE, AND ART', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9564, 'OPTICAL', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9565, 'PHARMACY', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9566, 'RECORD, CD, AND VIDEO', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9567, 'SPECIALTY STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9568, 'SPORTING GOODS', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9569, 'WINE AND LIQUOR', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9570, 'BOATING', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9571, 'THEATER', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9572, 'RACE TRACK', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9573, 'GOLF PRACTICE RANGE', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9574, 'HEALTH CLUB', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9575, 'BOWLING ALLEY', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9576, 'SPORTS ACTIVITIES', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9577, 'RECREATION CENTER', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9578, 'ATTORNEY', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9579, 'DENTIST', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9580, 'PHYSICIAN', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9581, 'REALTOR', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9582, 'RV PARK', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9583, 'MEDICAL SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9584, 'POLICE SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9585, 'VETERINARIAN SERVICE', 1, 10011);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9586, 'SPORTING AND INSTRUCTIONAL CAMP', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9591, 'CEMETERY', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9986, 'HOME IMPROVEMENT AND HARDWARE STORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9992, 'PLACE OF WORSHIP', 1, 10009);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9993, 'EMBASSY', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9994, 'COUNTY COUNCIL', 1, 10010);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9995, 'BOOKSTORE', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9996, 'COFFEE SHOP', 1, 10002);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9997, 'ALTERNATE FUEL STATION', 1, 10007);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9998, 'HAMLET', 1, 10008);
insert into ols_dir_categories (category_id, category_name, category_type_id, parent_id) values (9999, 'BORDER CROSSING', 1, 10007);
commit;

-- Check results
col category_name for a30
select c1.category_id, c1.category_name, count(*)
from ols_dir_categories c1, ols_dir_categories c2
where c2.parent_id = c1.category_id
group by c1.category_id, c1.category_name
order by c1.category_id;
