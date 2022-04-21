/*Lab2 Report <Filip Kjellgren (filkj254), Rasmus Lagerström (rasla833 )>*/
DROP TABLE IF EXISTS jbitem2 CASCADE;
DROP VIEW IF EXISTS jbsale_supply;
DROP VIEW IF EXISTS quan_view;
DROP VIEW IF EXISTS item_view;
DROP VIEW IF EXISTS debit_cost;
DROP VIEW IF EXISTS debit_cost2;


SOURCE company_schema.sql;
SOURCE company_data.sql;

/* Question 1 */

SELECT * FROM jbemployee;

/*
+------+--------------------+--------+---------+-----------+-----------+
| id   | name               | salary | manager | birthyear | startyear |
+------+--------------------+--------+---------+-----------+-----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |
+------+--------------------+--------+---------+-----------+-----------+
25 rows in set (0,00 sec)
*/

/* Question 2*/

SELECT name FROM jbdept ORDER BY name ASC;

/*
+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
| Women's          |
| Women's          |
+------------------+
19 rows in set (0,00 sec)

*/

/* Question 3*/

SELECT * FROM jbparts WHERE qoh = 0;

/*
+----+-------------------+-------+--------+------+
| id | name              | color | weight | qoh  |
+----+-------------------+-------+--------+------+
| 11 | card reader       | gray  |    327 |    0 |
| 12 | card punch        | gray  |    427 |    0 |
| 13 | paper tape reader | black |    107 |    0 |
| 14 | paper tape punch  | black |    147 |    0 |
+----+-------------------+-------+--------+------+
4 rows in set (0,00 sec)
*/

/* QUESTION 4 */

SELECT * FROM jbemployee WHERE salary >= 9000 AND salary <= 10000;

/*
+-----+----------------+--------+---------+-----------+-----------+
| id  | name           | salary | manager | birthyear | startyear |
+-----+----------------+--------+---------+-----------+-----------+
|  13 | Edwards, Peter |   9000 |     199 |      1928 |      1958 |
|  32 | Smythe, Carol  |   9050 |     199 |      1929 |      1967 |
|  98 | Williams, Judy |   9000 |     199 |      1935 |      1969 |
| 129 | Thomas, Tom    |  10000 |     199 |      1941 |      1962 |
+-----+----------------+--------+---------+-----------+-----------+
4 rows in set (0,00 sec)

*/

/* Question 5 */

SELECT *, (startyear-birthyear) as startage FROM jbemployee;

/*
+------+--------------------+--------+---------+-----------+-----------+----------+
| id   | name               | salary | manager | birthyear | startyear | startage |
+------+--------------------+--------+---------+-----------+-----------+----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |       18 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |        1 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |       30 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |       40 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |       38 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |       32 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |       22 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |       24 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |       49 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |       34 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |       21 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |       20 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |        0 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |       21 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |       21 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |       20 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |       26 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |       21 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |       19 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |       21 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |       23 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |       19 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |       19 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |       24 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |       15 |
+------+--------------------+--------+---------+-----------+-----------+----------+
25 rows in set (0,00 sec)

*/

/* Question 6 */

SELECT * FROM jbemployee WHERE name LIKE '%son,%';

/*
+----+---------------+--------+---------+-----------+-----------+
| id | name          | salary | manager | birthyear | startyear |
+----+---------------+--------+---------+-----------+-----------+
| 26 | Thompson, Bob |  13000 |     199 |      1930 |      1970 |
+----+---------------+--------+---------+-----------+-----------+
1 row in set (0,00 sec)
*/

/* Question 7*/
SELECT * FROM jbitem WHERE jbitem.supplier IN (SELECT jbsupplier.id FROM jbsupplier WHERE name = 'Fisher-Price');
/* Question 8*/
select jbitem.* from jbitem join jbsupplier on jbsupplier.name = 'Fisher-Price' AND jbsupplier.id = supplier;
/*
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
+-----+-----------------+------+-------+------+----------+
3 rows in set (0,00 sec)
*/

/* Question 9 */

select * from jbcity where id in (select city from jbsupplier);
/*
+-----+----------------+-------+
| id  | name           | state |
+-----+----------------+-------+
|  10 | Amherst        | Mass  |
|  21 | Boston         | Mass  |
| 100 | New York       | NY    |
| 106 | White Plains   | Neb   |
| 118 | Hickville      | Okla  |
| 303 | Atlanta        | Ga    |
| 537 | Madison        | Wisc  |
| 609 | Paxton         | Ill   |
| 752 | Dallas         | Tex   |
| 802 | Denver         | Colo  |
| 841 | Salt Lake City | Utah  |
| 900 | Los Angeles    | Calif |
| 921 | San Diego      | Calif |
| 941 | San Francisco  | Calif |
| 981 | Seattle        | Wash  |
+-----+----------------+-------+
15 rows in set (0,00 sec)
*/

/* QUESTION 10 */

select name, color from jbparts WHERE  weight > ALL (select weight from jbparts  where name = 'card reader');

/*
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.01 sec)
*/

/* QUESTION 11 */

select A.name, A.color from jbparts AS A inner join jbparts AS B on B.name = 'card reader' AND A.weight > B.weight; 

/*
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.00 sec)
*/

/* QUESTION 12 */
select AVG(weight) AS AVG_FOR_BLACK from jbparts where color = 'black';
/*select SUM(weight)/COUNT(*) AS AVG_FOR_BLACK from jbparts where color = 'black'; */

/*
+---------------+
| AVG_FOR_BLACK |
+---------------+
|      347.2500 |
+---------------+
1 row in set (0.00 sec)
*/

/* QUESTION 13 */

/* First create a view with relevant information */
CREATE VIEW quan_view AS select SUM(quan) 
AS total_quan, part, jbsupplier.name 
from jbsupply, jbsupplier 
where supplier IN (select id from jbsupplier 
where city IN (select id from jbcity where state ='Mass')) AND jbsupply.supplier = jbsupplier.id group by jbsupplier.name, part;
/*
+------------+------+--------------+
| total_quan | part | name         |
+------------+------+--------------+
|          2 |    1 | DEC          |
|         64 |    2 | DEC          |
|          2 |    3 | DEC          |
|          1 |    4 | DEC          |
|       1000 |    3 | Fisher-Price |
|       1000 |    4 | Fisher-Price |
+------------+------+--------------+
6 rows in set (0,00 sec)
*/
/* Select from the view and calculate the wanted data */
select quan_view.name, SUM(total_quan*jbparts.weight) AS Total_Weight_Supplied from quan_view, jbparts where quan_view.part = jbparts.id group by quan_view.name;

/*
+--------------+-----------------------+
| name         | Total_Weight_Supplied |
+--------------+-----------------------+
| DEC          |                  3120 |
| Fisher-Price |               1135000 |
+--------------+-----------------------+
2 rows in set (0,00 sec)
*/

/* QUESTION 14 */

CREATE TABLE jbitem2 (
  id int(11) NOT NULL,
  name varchar(20) DEFAULT NULL,
  dept int(11) NOT NULL,
  price int(11) DEFAULT NULL,
  qoh int(10) unsigned DEFAULT NULL,
  supplier int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY fk_item_dept (dept),
  KEY fk_item_supplier (supplier),
  CONSTRAINT fk_item_dept2 FOREIGN KEY (dept) REFERENCES jbdept (id),
  CONSTRAINT fk_item_supplier2 FOREIGN KEY (supplier) REFERENCES jbsupplier (id));

  insert into jbitem2 (select * from jbitem where jbitem.price < ALL (select AVG(price) from jbitem));

  /* Query OK, 14 rows affected (0.00 sec)
Records: 14  Duplicates: 0  Warnings: 0 */

/* QUESTION 15 */

CREATE VIEW item_view AS select * from jbitem where jbitem.price < ALL (select AVG(price) from jbitem);

/* Query OK, 0 rows affected (0.00 sec) */

/* QUESTION 16 */
/* A view is a virtual table based on a query from other tables or views. 

/*A view is considered dynamic since the data it contains can change and be manipulated even though we don't make active changes to it.
  For example if a table from which the view gathers its data, changes, the view will change accordingly.

The tables, on the other hand, are considered static because they only change when we explicitly alter them. */


/* Question 17 */
/* En view med sale identifier(debit) + (quantity*item.price) */
 

CREATE VIEW debit_cost AS select debit, SUM(jbsale.quantity*jbitem.price) AS Total_Cost from jbsale, jbitem WHERE id = item group by debit; 
SELECT * from debit_cost;
/* Query OK, 0 rows affected (0.01 sec) */

/*
mysql> select * from debit_cost;
+--------+------------+
| debit  | Total_Cost |
+--------+------------+
| 100581 |       2050 |
| 100582 |       1000 |
| 100586 |      13446 |
| 100592 |        650 |
| 100593 |        430 |
| 100594 |       3295 |
+--------+------------+
6 rows in set (0.00 sec)
*/

/* QUESTION 18 */

CREATE VIEW debit_cost2 AS select debit, SUM(jbsale.quantity*jbitem.price) AS Total_Cost from jbsale inner join jbitem on id = item group by debit; 

/*
mysql> select * from debit_cost2;
+--------+------------+
| debit  | Total_Cost |
+--------+------------+
| 100581 |       2050 |
| 100582 |       1000 |
| 100586 |      13446 |
| 100592 |        650 |
| 100593 |        430 |
| 100594 |       3295 |
+--------+------------+
6 rows in set (0.00 sec)
*/

/*
Both inner join and left join works in this case. This is because all items referenced in jbsale exist in jbitem.

Right join is not suitable because not all items in jbitem are referenced in jbsale. 
The price of items not mentioned in jbsale would therefore be multiplied with NULL and grouped to a NULL debit, resulting in a NULL NULL tuple.
*/

/* QUESTION 19 */
DELETE from jbsale where item in (SELECT jbitem.id from jbitem WHERE supplier IN (select jbsupplier.id from jbsupplier where city IN(select id from jbcity where name = 'Los Angeles')));

DELETE from jbitem WHERE supplier IN (select jbsupplier.id from jbsupplier where city IN(select id from jbcity where name = 'Los Angeles'));

DELETE from jbitem2 WHERE supplier IN (select jbsupplier.id from jbsupplier where city IN(select id from jbcity where name = 'Los Angeles'));
DELETE from jbsupplier where city IN(select id from jbcity where name = 'Los Angeles');


/* The first delete query did not fall through due to the fact that the jbitem(supplier) references supplier(id).
   To solve this, we had to delete the id's in jbitem which has references to the supplier we wanted to delete.
   But the jbitem(id) is referenced by foreign key jbsale(item).

   So first we deleted all tuples from jbsale where jbsale(item) -> jbitem(supplier) -> supplier(city) = Los Angeles. 

    Then we deleted tuples from jbitem.
    We also had to repeat this step for our newly created table jbitem2, which has the same foreign keys. 

    After this all suppliers in Los Angeles could be deleted.
*/

/* QUESTION 20 */



CREATE VIEW jbsale_supply AS
select jbsupplier.name AS Supplier, jbitem.name AS Item, jbitem.qoh + IFNULL(jbsale.quantity,0) AS q_supplied, IFNULL(jbsale.quantity,0) AS q_sold 
from jbitem 
inner join jbsupplier on jbitem.supplier = jbsupplier.id 
left join jbsale on jbitem.id = jbsale.item;

/*
mysql> select * from jbsale_supply;
+--------------+-----------------+------------+--------+
| Supplier     | Item            | q_supplied | q_sold |
+--------------+-----------------+------------+--------+
| Cannon       | Wash Cloth      |        575 |      0 |
| Levi-Strauss | Bellbottoms     |        600 |      0 |
| Playskool    | ABC Blocks      |        405 |      0 |
| Whitman's    | 1 lb Box        |        102 |      2 |
| Whitman's    | 2 lb Box, Mix   |         75 |      0 |
| Fisher-Price | Maze            |        200 |      0 |
| White Stag   | Jacket          |        301 |      1 |
| White Stag   | Slacks          |        325 |      0 |
| Playskool    | Clock Book      |        152 |      2 |
| Fisher-Price | The 'Feel' Book |        225 |      0 |
| Cannon       | Towels, Bath    |       1005 |      5 |
| Fisher-Price | Squeeze Ball    |        400 |      0 |
| Cannon       | Twin Sheet      |        751 |      1 |
| Cannon       | Queen Sheet     |        600 |      0 |
| White Stag   | Ski Jumpsuit    |        128 |      3 |
| Levi-Strauss | Jean            |        500 |      0 |
| Levi-Strauss | Shirt           |       1201 |      1 |
| Levi-Strauss | Boy's Jean Suit |        500 |      0 |
+--------------+-----------------+------------+--------+
18 rows in set (0,01 sec)
*/

select Supplier, SUM(q_supplied) AS total_supply, SUM(q_sold) AS total_sold from jbsale_supply group by Supplier;

/*
+--------------+--------------+------------+
| Supplier     | total_supply | total_sold |
+--------------+--------------+------------+
| Cannon       |         2931 |          6 |
| Fisher-Price |          825 |          0 |
| Levi-Strauss |         2801 |          1 |
| Playskool    |          557 |          2 |
| White Stag   |          754 |          4 |
| Whitman's    |          177 |          2 |
+--------------+--------------+------------+
6 rows in set (0,00 sec)
*/