#data cleaning
#WE WILL REMOVE DUPLICATES,STANDARDIZE DATA TYPES, DELETE USELESS RECORDS WITH NULLS AND BLANKS,REMOVE USELESS COLUMNS
select * from layoffs;

#prevnts deadly mistakes
create table layoffs_stagging like layoffs;

insert layoffs_stagging 
Select * from layoffs;

select * from layoffs_stagging;

#removing duplicates



WITH DUPLICATE_CTE AS 
(
SELECT *, 
ROW_NUMBER() OVER(
partition by COMPANY,LOCATION,INDUSTRY,TOTAL_LAID_OFF,PERCENTAGE_LAID_OFF, `Date`,STAGE,COUNTRY,FUNDS_RAISED_MILLIONS) as row_num #any row number above 2 =duplicate
FROM LAYOFFS_STAGGING
)

SELECT * FROM DUPLICATE_CTE WHERE ROW_NUM >1;

CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO LAYOFFS_STAGGING2
SELECT *, 
ROW_NUMBER() OVER(
partition by COMPANY,LOCATION,INDUSTRY,TOTAL_LAID_OFF,PERCENTAGE_LAID_OFF, `Date`,STAGE,COUNTRY,FUNDS_RAISED_MILLIONS) as row_num #any row number above 2 =duplicate
FROM LAYOFFS_STAGGING;

delete FROM LAYOFFS_STAGGING2 where row_num>1;

#trim the values so they fit well
select company,trim(company) from layoffs_stagging2;

update layoffs_stagging2
set company =trim(company);

#CHANGING RECORDS WHICH ARE THE SAME BUT SAVED IN A DIFFERENT FORMAT
select DISTINCT INDUSTRY from lAYOFFS_STAGGING2 ORDER BY 1 ; # step 1ORDERS THE DISTINCT COLOUMNS BY THE FIRST COLOUMN

SELECT * FROM layoffs_stagging2 WHERE INDUSTRY = 'Crypto%'; #step 2


UPDATE LAYOFFS_STAGGING2 #step 3
SET INDUSTRY = 'CRYPTO'
WHERE INDUSTRY LIKE 'CRYPTO%';

select distinct industry from layoffs_stagging2; # step 2

#fixing country issues
SELECT * FROM layoffs_stagging2 WHERE COUNTRY LIKE 'united states%';
update layoffs_stagging2 SET COUNTRY = TRIM(TRAILING '.' FROM COUNTRY) WHERE COUNTRY LIKE 'UNITED STATES';
#changing the date data type

select `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y') # will convert the date text data type into a proper date which can be used for visualizations
FROM layoffs_stagging2;

update layoffs_stagging2 
set date = STR_TO_DATE(`date`, '%m/%d/%Y');

#only change datatype on stagging table not the actual table 

alter table layoffs_stagging2
modify column `date` DATE;

#NULLS AND BLANK VALUES 
SELECT * FROM layoffs_stagging2;

SELECT * FROM layoffs_stagging2 WHERE TOTAL_laid_off is null and percentage_laid_off is null;

SELECT * FROM layoffs_stagging2 WHERE industry is null or industry = '';

SELECT * FROM layoffs_stagging2 WHERE COMPANY = 'AIRBNB';

#method to identifying nulls and blanks
SELECT t1.industry,t2.industry 
FROM layoffs_stagging2 T1
JOIN layoffs_stagging2 T2
	ON T1.company=T2.COMPANY
WHERE (T1.INDUSTRY IS NULL or t1.INDUSTRY='') #where the industry is either null or blank
AND T2.INDUSTRY IS NOT NULL; #PURPOSE IT IS A SELFJOIN To identify rows with missing industry info that can be filled in using other rows for the same company (self-join).

UPDATE layoffs_stagging2
SET INDUSTRY = NULL
WHERE INDUSTRY = '';
# WE USE THE SET KEYWORD SET TO MAKE THE NULL VALUES OF T1 TO THE NOT NULL VALUES/PRESENT VALUES OF T2
UPDATE layoffs_stagging2 T1
JOIN layoffs_stagging2 T2
	ON T1.company=T2.COMPANY
SET T1.industry=T2.industry #UPDATES T1.INDUSTRY TO BE THE SAME AS T2.INDUSTRY
WHERE (T1.INDUSTRY IS NULL or t1.INDUSTRY='') #where the industry is either null or blank
AND T2.INDUSTRY IS NOT NULL ;
 
 #important: key area where I struggled remember to refresh schemas when updating and also reconnect database to make see updates 

select * from layoffs_stagging2  where company ='Airbnb';

select * from layoffs_stagging2 where  company like 'Bally%'; # this null for industry has no duplicates

delete  # we are deleting these nulls because they have no duplicates they make our data dirty we cant trust that data
from layoffs_stagging2
where total_laid_off is null 
and percentage_laid_off is null;

select * from layoffs_stagging2;

alter table layoffs_stagging2 
drop column row_num;

#data is clean (:


 






