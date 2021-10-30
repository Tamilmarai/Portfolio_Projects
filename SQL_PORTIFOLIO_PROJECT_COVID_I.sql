
/*SELECT THE REQUIRED FIELDS IN THE TABLES */
use Portfolio_Project
go 

Select location,date,total_cases,new_cases,total_deaths,population
From ..[Covid_Deaths_20211025]
Where continent is not null 
Order by 1,2 desc

--TOTAL DEATHS VS TOTAL CASES

/*SELECT THE REQUIRED TABLES AND CALCUATION OF DEATH PERCENTAGE */

--COUNTRIES
Select location,date,total_cases,new_cases,total_deaths,population,(CAST(total_deaths as int)/total_cases)*100 as Death_Percentage
From ..[Covid_Deaths_20211025]
Where continent is not null 
Order by 1,2 desc

/*DEATH PERCENTAGE IN INDIA WITH DATE*/
--INDIA
Select location,date,total_cases,new_cases,total_deaths,population,(CAST(total_deaths as int)/total_cases)*100 as Death_Percentage
From ..[Covid_Deaths_20211025]
Where location like '%India'
Order by 1,2 desc


--TOTAL CASES VS POPULATION

/*SELECT THE REQUIRED TABLES AND CALCUATION OF TOTAL CASE PERCENTAGE */
--COUNTRIES
Select location,date,total_cases,new_cases,total_deaths,population,(total_cases/population)*100 as Total_Case_Percentage
From ..[Covid_Deaths_20211025]
Where continent is not null  
Order by 1,2 desc
--INDIA
Select location,date,total_cases,new_cases,total_deaths,population,(total_cases/population)*100 as Total_Case_Percentage
From ..[Covid_Deaths_20211025]
Where location like '%India' 
Order by 1,2 desc


-- MAX INFECTION RATE PER 
-- CONTINENT
Select location,population,MAX(total_cases) as Hightest_Infection_Rate,MAX((total_cases/population))*100 as Hightest_Infection_Rate_Percentage
From ..[Covid_Deaths_20211025]
Where continent is null and   location not in ( 'World', 'International','European Union') and population is not null
Group by continent, location,population
Order by Hightest_Infection_Rate_Percentage desc

--COUNTRY
Select location,population,MAX(total_cases) as Hightest_Infection_Rate,MAX((total_cases/population))*100 as Hightest_Infection_Rate_Percentage
From ..[Covid_Deaths_20211025]
Where continent is not null 
Group by location,population
Order by Hightest_Infection_Rate_Percentage desc



--MAXIMUM DEATH COUNT 

-- CONTINENT
Select location,MAX(CAST(total_deaths as int)) as Highest_Death_Count_per_Continent
From ..[Covid_Deaths_20211025]
Where continent is  null and   location not in ( 'World', 'International','European Union')
Group by location
Order by Highest_Death_Count_per_Continent desc
--COUNTRY
Select location,population,MAX(CAST(total_deaths as int)) as Highest_Death_per_Country
From ..[Covid_Deaths_20211025]
Where continent is not null 
Group by location,population
Order by Highest_Death_per_Country desc

/*GLOBAL NUMBERS */

/*DEATH PERCENTAGE GLOBALLY PER DATE*/
Select date,SUM(new_cases) as total_new_cases,SUM(CONVERT(int,new_deaths)) as total_new_deaths,SUM(CONVERT(int,new_deaths))/SUM(new_cases)*100 as New_Death_Percentage
From ..[Covid_Deaths_20211025]
Where continent is not null -- and   location not in ( 'World', 'International','European Union')
Group by date
Order by 1,2 desc


/*JOINS ON COVID DEATHS AND COVID VACCINATION TABLE */

--TOTAL POPULATION VS VACCINATION
--COUNTRIES
Use Portfolio_Project
Go 
Select  COV_D.continent,COV_D.location,COV_D.date,COV_D.population,COV_V.new_vaccinations,
SUM(CAST(COV_V.new_vaccinations as BIGINT)) OVER (PARTITION BY COV_D.location ORDER BY COV_D.location ,COV_D.date) as Rolling_Count_Vaccinated
From ..[Covid_Deaths_20211025] COV_D
JOIN ..[Covid_Vaccination_20211025] COV_V
	ON COV_D.location = COV_V.location
	AND  COV_D.date = COV_V.date
Where COV_D.continent is not null -- and COV_D.location like'%Indi%'
Order by 2,3 
-- INDIA
Use Portfolio_Project
Go 
Select  COV_D.continent,COV_D.location,COV_D.date,COV_D.population,COV_V.new_vaccinations,
SUM(CAST(COV_V.new_vaccinations as BIGINT)) OVER (PARTITION BY COV_D.location ORDER BY COV_D.location ,COV_D.date) as Rolling_Count_Vaccinated
From ..[Covid_Deaths_20211025] COV_D
JOIN ..[Covid_Vaccination_20211025] COV_V
	ON COV_D.location = COV_V.location
	AND  COV_D.date = COV_V.date
Where COV_D.continent is not null  and COV_D.location like'%Indi%'
Order by 2,3 

--Creating a CTE to find (Rolling_Count_Vaccinated/population)*100 as Rolling_Count_Vaccinated_Percentage
--COUNTRIES
USE Portfolio_Project
go

WITH PopVsVac(continent,location,date,population,new_vaccinations,Rolling_Count_Vaccinated)

as
(
Select  COV_D.continent,COV_D.location,COV_D.date,COV_D.population,COV_V.new_vaccinations,
SUM(CAST(COV_V.new_vaccinations as BIGINT)) OVER (PARTITION BY COV_D.location ORDER BY COV_D.location ,COV_D.date) as Rolling_Count_Vaccinated
From ..[Covid_Deaths_20211025] COV_D
JOIN ..[Covid_Vaccination_20211025] COV_V
	ON COV_D.location = COV_V.location
	AND  COV_D.date = COV_V.date
Where COV_D.continent is not null -- and COV_D.location like'%Indi%'
 
)


Select *, (Rolling_Count_Vaccinated/population)*100 as Roling_Count_Vaccinated_Percentage
From PopVsVac

/*Finding Total_Vacc_percent Using Temp Table */

DROP TABLE IF EXISTS Total_Vacc_percent
CREATE TABLE Total_Vacc_percent
(
continent nvarchar(255),
location nvarchar(255),
population float,
new_vaccinations  nvarchar(255),
Rolling_Count_Vaccinated numeric
)

INSERT INTO  Total_Vacc_percent
Select  COV_D.continent,COV_D.location,COV_D.population,COV_V.new_vaccinations,
SUM(CAST(COV_V.new_vaccinations as BIGINT)) OVER (PARTITION BY COV_D.location ORDER BY COV_D.location ,COV_D.date) as Rolling_Count_Vaccinated
From ..[Covid_Deaths_20211025] COV_D
JOIN ..[Covid_Vaccination_20211025] COV_V
	ON COV_D.location = COV_V.location
	AND  COV_D.date = COV_V.date
Where COV_D.continent is not null


--COUNTRIES
Select  continent,location,SUM(Rolling_Count_Vaccinated) as total_Vacc,
SUM(population) as total_Pop,(SUM(Rolling_Count_Vaccinated)/SUM(population))*100 as Total_Vacc_percent 
From Total_Vacc_percent
Where continent is not null --and location like '%IND%'
Group by continent, location
Order by 1,2

--INDIA AND INDONESIA

Select  continent,location,SUM(Rolling_Count_Vaccinated) as total_Vacc,
SUM(population) as total_Pop,(SUM(Rolling_Count_Vaccinated)/SUM(population))*100 as Total_Vacc_percent 
From Total_Vacc_percent
Where continent is not null and location like '%IND%'
Group by continent, location
Order by 1,2

/*CREATIG VIEW */

--CREATE VIEW Total_Vacc_percent_Pop
--DROP View IF EXISTS Total_Vacc_percent_Pop
Create View Total_Vacc_percent_Pop
as
Select  location,SUM(Rolling_Count_Vaccinated) as total_Vacc,
SUM(population) as total_Pop,(SUM(Rolling_Count_Vaccinated)/SUM(population))*100 as Total_Vacc_percent 
From Total_Vacc_percent
Where continent is not null
Group by  location

-- GLOBAL VIEW Global_New_Death_Percentage PER DAY
--DROP View IF EXISTS Global_New_Death_Percentage
Create View Global_New_Death_Percentage
as
Select date,SUM(new_cases) as total_new_cases,SUM(CONVERT(int,new_deaths)) as total_new_deaths,SUM(CONVERT(int,new_deaths))/SUM(new_cases)*100 as New_Death_Percentage
From ..[Covid_Deaths_20211025]
Where continent is not null -- and   location not in ( 'World', 'International','European Union')
Group by date

-- TOTAL GLOBAL NUMBERS
--DROP View IF EXISTS Total_Global_New_Death_Percentage
Create View Total_Global_New_Death_Percentage
as
Select SUM(new_cases) as total_new_cases,SUM(CONVERT(int,new_deaths)) as total_new_deaths,SUM(CONVERT(int,new_deaths))/SUM(new_cases)*100 as New_Death_Percentage
From ..[Covid_Deaths_20211025]
Where continent is not null -- and   location not in ( 'World', 'International','European Union')



