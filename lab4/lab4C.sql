
/* Cascade not working, tables are removed in order not violating constraints */
DROP TABLE IF EXISTS reserved_seat CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS contact CASCADE;
DROP TABLE IF EXISTS passenger CASCADE;
DROP TABLE IF EXISTS card_holder CASCADE;
DROP TABLE IF EXISTS flight CASCADE;
DROP TABLE IF EXISTS weekly_flight CASCADE;
DROP TABLE IF EXISTS weekday_factor CASCADE;
DROP TABLE IF EXISTS profit_factor CASCADE;
DROP TABLE IF EXISTS flight_route CASCADE;
DROP TABLE IF EXISTS airport CASCADE;

DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;

DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;

DROP TRIGGER IF EXISTS generateTicket;

DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;

DROP VIEW IF EXISTS allFlights;


CREATE TABLE passenger(
    passport_number INTEGER,
    name VARCHAR(30),
    PRIMARY KEY(passport_number)
);

CREATE TABLE contact(
    passport_number INTEGER,
    email VARCHAR(30),
    phone_number BIGINT,
    PRIMARY KEY(passport_number),
    FOREIGN KEY(passport_number) REFERENCES passenger(passport_number) 
);

CREATE TABLE card_holder(
    card_num BIGINT,
    name VARCHAR(30),
    PRIMARY KEY(card_num)
);

CREATE TABLE reservation(
    res_number INTEGER NOT NULL AUTO_INCREMENT,
    is_payed BOOLEAN DEFAULT FALSE,
    payed_by BIGINT DEFAULT NULL,
    no_of_res INTEGER,
    contact INTEGER,
    flight INTEGER,
    price INTEGER,
    PRIMARY KEY(res_number),
    FOREIGN KEY(contact) REFERENCES contact(passport_number),
    FOREIGN KEY(payed_by) REFERENCES card_holder(card_num) 
);

CREATE TABLE reserved_seat(
    res_number INTEGER,
    passport_number INTEGER,
    ticket_number INTEGER DEFAULT NULL,
    PRIMARY KEY(res_number, passport_number),
    FOREIGN KEY(res_number) REFERENCES reservation(res_number),
    FOREIGN KEY(passport_number) REFERENCES passenger(passport_number) 
);

CREATE TABLE profit_factor(
    year INTEGER,
    factor DOUBLE,
    PRIMARY KEY(year)
);

CREATE TABLE weekday_factor(
    day VARCHAR(10),
    year INTEGER,
    factor DOUBLE,
    PRIMARY KEY(year, day)
);

CREATE TABLE weekly_flight(
    ID INTEGER NOT NULL AUTO_INCREMENT,
    day VARCHAR(10),
    year INTEGER,
    dep_time TIME,
    flight_route INTEGER,
    PRIMARY KEY(ID),
    FOREIGN KEY(year) REFERENCES profit_factor(year),
    FOREIGN KEY(year, day) REFERENCES weekday_factor(year, day) 
);

CREATE TABLE flight(
    flight_no INTEGER NOT NULL AUTO_INCREMENT,
    week INTEGER,
    weekly_flight INTEGER,
    PRIMARY KEY(flight_no),
    FOREIGN KEY(weekly_flight) REFERENCES weekly_flight(ID) 
);

CREATE TABLE airport(
  airport_code VARCHAR(3),
  name VARCHAR(30),
  country VARCHAR(30),
  PRIMARY KEY(airport_code)  
);

CREATE TABLE flight_route(
    ID INTEGER NOT NULL AUTO_INCREMENT,
    route_price INTEGER,
    dep_airport VARCHAR(3),
    arr_airport VARCHAR(3),
    year INTEGER,
    PRIMARY KEY(ID),
    FOREIGN KEY(dep_airport) REFERENCES airport(airport_code),
    FOREIGN KEY(arr_airport) REFERENCES airport(airport_code) 
);

ALTER TABLE weekly_flight ADD FOREIGN KEY(flight_route) REFERENCES flight_route(ID);
ALTER TABLE reservation ADD FOREIGN KEY(flight) REFERENCES flight(flight_no);

/* DATABASE DONE, TIME FOR PROCEDURES */ 

delimiter //

CREATE PROCEDURE addYear(IN year INTEGER, IN factor DOUBLE)
    BEGIN
    INSERT INTO profit_factor(year, factor)
    VALUES(year, factor);
    END;
    //

CREATE PROCEDURE addDay(IN year INTEGER, IN day VARCHAR(10), IN factor DOUBLE)
    BEGIN
    INSERT INTO weekday_factor(day, year, factor)
    VALUES(day, year, factor);
    END;
    //



CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
    BEGIN
    INSERT INTO airport(airport_code, name, country)
    VALUES(airport_code, name, country);
    END;
    //

CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INTEGER, IN routeprice DOUBLE)
    BEGIN
    INSERT INTO flight_route(route_price, dep_airport, arr_airport, year)   /* Also year hear ?? */
    VALUES(routeprice, departure_airport_code, arrival_airport_code, year);
    END;
    //

CREATE PROCEDURE addFlight(IN dep VARCHAR(3), IN arr VARCHAR(3), IN year INTEGER, IN day VARCHAR(10), IN dep_time TIME)
    BEGIN
    DECLARE route_ID INTEGER;
    DECLARE weekly_ID INTEGER;
    DECLARE cnt INTEGER;
    select flight_route.ID INTO route_ID from flight_route where flight_route.arr_airport=arr AND flight_route.dep_airport=dep AND flight_route.year = year;
    INSERT INTO weekly_flight(flight_route, dep_time, year, day)
    VALUES(route_ID, dep_time, year, day);
    select weekly_flight.ID INTO weekly_ID from weekly_flight where weekly_flight.flight_route = route_ID AND weekly_flight.dep_time=dep_time AND weekly_flight.year=year AND weekly_flight.day=day;

    SET cnt = 1;
  
    WHILE cnt < 53 DO   
        INSERT INTO flight(week, weekly_flight) VALUES(cnt, weekly_ID);
        SET cnt = cnt + 1;
    END WHILE;
    END;
    //

/* PROCEDURES DONE, TIME FOR FUNCTIONS */

CREATE FUNCTION calculateFreeSeats(flight_no INTEGER)
    RETURNS INTEGER
    BEGIN
    DECLARE booked INTEGER;
    DECLARE free INTEGER;
    select IFNULL(SUM(no_of_res),0) INTO booked from reservation where reservation.flight = flight_no AND reservation.is_payed = TRUE;
    SET free = 40 - booked;
    RETURN free;
    END;
    //

CREATE FUNCTION calculatePrice(flight_no INTEGER)
    RETURNS DOUBLE
    BEGIN
    DECLARE totalPrice DOUBLE;
    DECLARE route_price DOUBLE;
    DECLARE w_factor DOUBLE;
    DECLARE p_factor DOUBLE;
    
    
    select flight_route.route_price INTO route_price 
    from flight_route, flight, weekly_flight 
    where flight.flight_no = flight_no 
    AND flight.weekly_flight = weekly_flight.ID 
    AND weekly_flight.flight_route = flight_route.ID; 
    
    SELECT factor INTO w_factor
    FROM weekday_factor, weekly_flight, flight 
    WHERE weekday_factor.year = weekly_flight.year 
    AND weekday_factor.day = weekly_flight.day 
    AND flight.flight_no = flight_no 
    AND flight.weekly_flight = weekly_flight.ID;

    SELECT factor INTO p_factor
    FROM profit_factor, weekly_flight, flight
    WHERE profit_factor.year = weekly_flight.year
    AND flight.flight_no = flight_no 
    AND flight.weekly_flight = weekly_flight.ID;
    
    /* PRICE = Routeprice*weekdayfactor* ((#booked+1)/40) * profitfactor  */
    SET totalPrice = route_price*w_factor*p_factor*((40-calculateFreeSeats(flight_no)+1)/40);
    
    RETURN totalPrice;
    END;
    //

/* Functions done for calculating price and free seats*/



CREATE TRIGGER generateTicket
AFTER UPDATE 
ON reservation
FOR EACH ROW
BEGIN
    IF NEW.is_payed=TRUE AND OLD.is_payed = FALSE THEN
        UPDATE reserved_seat SET ticket_number = CAST(RAND()*10000000 AS INT) WHERE reserved_seat.res_number = OLD.res_number;
    END IF;
END;
//

/* TRIGGER DONE */

CREATE PROCEDURE addReservation(IN dep VARCHAR(3), IN arr VARCHAR(3), IN year INTEGER, IN week INTEGER, IN day VARCHAR(10), IN _time TIME, IN no_of_pass INTEGER, OUT res_number INTEGER)
BEGIN
DECLARE flight_nr INTEGER;
    
    select flight.flight_no INTO flight_nr from flight where flight.week = week AND flight.weekly_flight IN
    (select weekly_flight.ID from weekly_flight where weekly_flight.year = year AND weekly_flight.dep_time=_time AND weekly_flight.day = day
    AND weekly_flight.flight_route IN(select ID from flight_route where flight_route.year=year AND flight_route.dep_airport=dep AND flight_route.arr_airport=arr));
    
    IF flight_nr IS NULL THEN
        SELECT 'COULD NOT FIND FLIGHT' AS 'ERROR';
    ELSEIF calculateFreeSeats(flight_nr) < no_of_pass THEN 
        SELECT 'NOT ENOUGH FREE SEATS TO COMPLETE RESERVATION' AS 'ERROR';
    ELSE
        INSERT INTO reservation (flight, no_of_res) 
        VALUES(flight_nr, no_of_pass);
        SELECT LAST_INSERT_ID() INTO res_number; /*Selects the last added primary key = res_number*/
    END IF;
END;
//


CREATE PROCEDURE addPassenger(IN reservation_number INTEGER, IN passport_number INTEGER, IN name VARCHAR(30))
BEGIN
    DECLARE stated_amount INTEGER;
    DECLARE actual_amount INTEGER;
    select no_of_res INTO stated_amount from reservation where res_number=reservation_number;
    IF EXISTS (SELECT res_number FROM reservation WHERE res_number = reservation_number) THEN
        IF EXISTS (SELECT res_number FROM reservation WHERE res_number = reservation_number AND is_payed=FALSE) THEN
            IF NOT EXISTS (SELECT passenger.passport_number FROM passenger WHERE passenger.passport_number = passport_number)  THEN /* Create passenger if not exists already */
                INSERT INTO passenger VALUES(passport_number, name);
            END IF;
            
            INSERT INTO reserved_seat (res_number, passport_number) VALUES(reservation_number, passport_number);
            SELECT COUNT(*) INTO actual_amount FROM reserved_seat WHERE res_number = reservation_number;
            IF actual_amount > stated_amount THEN
                UPDATE reservation SET no_of_res = actual_amount WHERE res_number = reservation_number;
            END IF;
        ELSE
            SELECT 'RESERVATION IS ALREADY PAYED' AS 'ERROR';
        END IF;
    ELSE
        SELECT 'RESERVATION NUMBER DOES NOT EXIST' AS 'ERROR';
    END IF;
END;
//

CREATE PROCEDURE addContact(IN reservation_number INTEGER, IN passport_number INTEGER, IN email VARCHAR(30), IN phone BIGINT)
BEGIN
    IF EXISTS (SELECT res_number FROM reservation WHERE reservation.res_number = reservation_number) THEN
        IF EXISTS (SELECT passport_number FROM passenger WHERE passenger.passport_number = passport_number) THEN /* check if passenger exists */
            IF NOT EXISTS (SELECT passport_number FROM contact WHERE contact.passport_number = passport_number) THEN    /* Check if already contact */
                INSERT INTO contact VALUES(passport_number, email, phone);
            END IF;
            UPDATE reservation SET contact = passport_number WHERE res_number = reservation_number;
        ELSE
            SELECT 'CONTACT IS NOT A PASSENGER' AS 'ERROR';
        END IF;
    ELSE
        SELECT 'RESERVATION DOES NOT EXIST' AS 'ERROR';
    END IF;
END;
//

CREATE PROCEDURE addPayment(IN reservation_number INTEGER, IN card_name VARCHAR(30), IN card_number BIGINT)
BEGIN
    DECLARE f_no INTEGER;
    DECLARE no_of_pass INTEGER;
    DECLARE contact INTEGER;
    
    select reservation.no_of_res INTO no_of_pass from reservation where res_number = reservation_number;
    select reservation.flight INTO f_no from reservation where res_number = reservation_number;
    select reservation.contact INTO contact from reservation where res_number = reservation_number;

    IF EXISTS (select res_number from reservation where res_number = reservation_number) THEN
        IF calculateFreeSeats(f_no) < no_of_pass THEN
            DELETE from reserved_seat WHERE res_number = reservation_number;
            DELETE FROM reservation WHERE res_number = reservation_number;
            DELETE FROM contact WHERE passport_number NOT IN (SELECT passport_number FROM reserved_seat);
            DELETE FROM passenger WHERE passport_number NOT IN (SELECT passport_number FROM reserved_seat);
            SELECT 'NOT ENOUGH SEATS, DELETING RESERVATION' AS 'ERROR';
        ELSE
            IF contact IS NOT NULL AND calculateFreeSeats(f_no) >= no_of_pass THEN
                IF NOT EXISTS (select card_num from card_holder where card_holder.card_num = card_number) THEN
                    INSERT INTO card_holder VALUES(card_number, card_name);
                END IF;
                UPDATE reservation SET payed_by=card_number, price=calculatePrice(f_no), is_payed=TRUE WHERE res_number = reservation_number;
            ELSE
                SELECT 'THE RESERVATION COULD NOT BE PAYED FOR' AS 'ERROR';
            END IF;
        END IF;
    ELSE
        SELECT 'RESERVATION DOES NOT EXIST' AS 'ERROR';
    END IF;
END;
//

delimiter ;

/*Create a view allFlights containing all flights in your database with the following
information: departure_city_name, destination_city_name, departure_time,
departure_day, departure_week, departure_year, nr_of_free_seats,
current_price_per_seat. See the testcode for an example of how it can look like.*/


CREATE VIEW allFlights AS
SELECT dep.name AS departure_city_name, 
arr.name AS destination_city_name, 
weekly_flight.dep_time AS departure_time, 
weekly_flight.day AS departure_day, 
flight.week AS departure_week, 
weekly_flight.year AS departure_year, 
calculateFreeSeats(flight.flight_no) AS nr_of_free_seats, 
calculatePrice(flight.flight_no) AS current_price_per_seat
FROM airport AS dep, airport AS arr, weekly_flight, flight, flight_route
WHERE flight.weekly_flight = weekly_flight.ID 
AND flight_route.ID = weekly_flight.flight_route
AND flight_route.dep_airport = dep.airport_code
AND flight_route.arr_airport = arr.airport_code;

/*ASSIGNMENT 1-7 DONE ABOVE*/

/*  QUESTION 8
    a) How can you protect the credit card information in the database from hackers?

    Assuming the hacker gained access to the credit card tuples, then the credit card numbers should not be stored in plain text.
    We suggest some kind of encryption algorithm that makes it difficult to decrypt the values back into the actual card numbers.

    Assuming the hacker have access to the database as a regular user, then we should make sure that the hacker doesn't have permission to view
    credit card information, nor making changes to them. First of all, we can make sure that a user only can modify the database by using our pre-made
    procedures. In this way, we can control what the malicious user can do, and can't do. We can also prevent hackers by adding some sort of access control to
    the credit card tuples. 

    To prevent interception of data packets between application and database server we suggest using a secure transport layer protocol. 

    b) Give three advantages of using stored procedures in the database (and thereby
    execute them on the server) instead of writing the same functions in the front-
    end of the system (in for example java-script on a web-page)

    One advantage of using stored procedures is that it reduces the amount of data transferred between application and database server. 
    As an example: If the application would like to perform the addPayment operation without using the procedure, it would have to send many 
    SQL statements to the database. While using the stored procedure it only has to provide the required arguments. 

    A second advantage of using stored procedures is that we can make sure that every modification to the database will be correct. Since the 
    creator of the database writes the stored procedures, they can make sure that every stored procedure performs only the action it is intended to.
    Stored procedures is also efficient in the way that the clients doen't have to create their own functions, which reduces the effort to use the database.

    Finally, store procedures make the database easy to maintain. If we would modify the behaviour of a store procedure, no modification is necessary 
    at the application. The application can call the procedure just as it did before, assuming the arguments were not changed. 
*/

/*  QUESTION 9

    a) In session A, add a new reservation.

    DONE

    b) Is this reservation visible in session B? Why? Why not?

        No it is not visible in session B. This is due to the fact that session A has not committed the change to the database.  
        Because the DBMS enforces the ACID properties, any other session should not be able to see a new state of the database 
        until the transaction in session A is completed in its entirety. This means that a transaction has to be finished in its
        entirety or not at all, leading to transactions being seen as isolated transaction even though other transactions can be
        done concurrently. 

    c) What happens if you try to modify the reservation from A in B? Explain what
    happens and why this happens and how this relates to the concept of isolation
    of transactions.

        When we try to modify the reservation in session B the statement is not executed until the transaction in session A is committed. 
        Because of MySQL implicit use of locks, session A acquires a write lock on the inserted tuples that session B is trying to modify.
        The write lock is released by session A as soon as we commit, then B acquires the lock and can make modifcations to the newly
        created tuples. 
        See b) above for the concept of isolation.

*/


/*  QUESTION 10
    a) Did overbooking occur when the scripts were executed? If so, why? If not,
    why not?
    
    Yes an overbooking was possible to perform when executing the booking script from two terminals at exactly the same time.
    Simply this is because the both sessions simultaneously check the amount of free seats. They both see 40 free seats and then proceed to 
    complete the payment. 

    b) Can an overbooking theoretically occur? If an overbooking is possible, in what
    order must the lines of code in your procedures/functions be executed.
    
    Obviously an overbooking is possible in our implementation. More specifically the critical region is the following IF-statement in the 
    addPaymen procedure:

    IF contact IS NOT NULL AND calculateFreeSeats(f_no) >= no_of_pass THEN
        IF NOT EXISTS (select card_num from card_holder where card_holder.card_num = card_number) THEN
            INSERT INTO card_holder VALUES(card_number, card_name);
        END IF;
        UPDATE reservation SET payed_by=card_number, price=calculatePrice(f_no), is_payed=TRUE WHERE res_number = reservation_number;
    ELSE
        SELECT 'THE RESERVATION COULD NOT BE PAYED FOR' AS 'ERROR';
    END IF;

    Overbooking occurs when both sessions complete the call to calculateFreeSeats(f_no) before either of the sessions performs the UPDATE reservation statement.
    It is only after one of the sessions have finished the UPDATE reservation statement that calculateFreeSeats(f_no) would generete a different outcome.

    c) Try to make the theoretical case occur in reality by simulating that multiple
    sessions call the procedure at the same time. To specify the order in which the
    lines of code are executed use the MySQL query SELECT sleep(5); which
    makes the session sleep for 5 seconds. Note that it is not always possible to
    make the theoretical case occur, if not, motivate why.

    The theretical case occured in our test, due to perfect timing of calling the scripts.
    However, we can efficiently generate an overbooking with the following sleep placement:

    IF contact IS NOT NULL AND calculateFreeSeats(f_no) >= no_of_pass THEN
        IF NOT EXISTS (select card_num from card_holder where card_holder.card_num = card_number) THEN
            INSERT INTO card_holder VALUES(card_number, card_name);
        END IF;
        SELECT SLEEP(5);
        UPDATE reservation SET payed_by=card_number, price=calculatePrice(f_no), is_payed=TRUE WHERE res_number = reservation_number;
        ELSE
            SELECT 'THE RESERVATION COULD NOT BE PAYED FOR' AS 'ERROR';
        END IF;
    
    d) Modify the testscripts so that overbookings are no longer possible using
    (some of) the commands START TRANSACTION, COMMIT, LOCK TABLES, UNLOCK
    TABLES, ROLLBACK, SAVEPOINT, and SELECT...FOR UPDATE. Motivate why your
    solution solves the issue, and test that this also is the case using the sleep
    implemented in 10c. Note that it is not ok that one of the sessions ends up in a
    deadlock scenario. Also, try to hold locks on the common resources for as
    short time as possible to allow multiple sessions to be active at the same time.

    To prevent overbooking we can acquire locks on tables before the addPayment call and release them directly after.
    Essentially we only want to the reservation table, but the database requires us to take locks on all tables used in the procedure.
    See the code snippet below.
    
    LOCK TABLES reservation write, reserved_seat write, card_holder write, passenger write, contact write, weekday_factor write, profit_factor write, 
    flight_route write, flight write, weekly_flight write;
    CALL addPayment (@a, "Sauron",7878787878);
    UNLOCK TABLES;
    

    INDEX QUESTION

    It would be useful to index the reservation table on the flight field. Since reservations would be sorted by reservation number as default, it might
    take time to find every reservation connected to a certain flight. By doing this, we will get index file sorted on flight, which could be useful if
    something happens to a flight, and we want to make changes to the reservations connected to it. 

    So in formal terms we have an index on a non-ordering, non-key field. 

    CREATE INDEX Flight_Res
    ON reservation(flight);


*/