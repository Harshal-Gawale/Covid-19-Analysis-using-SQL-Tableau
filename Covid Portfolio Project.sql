
---Selecting Data to use

Select Location,date, total_cases, new_cases,total_deaths, population
From PortfolioProject..Covid_Deaths
Where Continent is not Null
order by 1,2


----Looking at Total cases Vs Total Deaths

Select Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
where Location Like '%India%' and Continent is not Null
order by 1,2

---Looking at total cases Vs Population
---Showing percentage of population got Covid

Select Location,date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
where Location Like '%India%' and Continent is not Null
order by 1,2

---Looking at Countries with Highest Infection Rates

Select Location, population, max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as InfectedPopulationInfected
From PortfolioProject..Covid_Deaths
Where Continent is not Null
Group by location, population
order by InfectedPopulationInfected Desc

--Showing  Countries with Highest Death Counts

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
Where Continent is not Null
Group by location
order by TotalDeathCount Desc

--Details by Continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
Where Continent is not Null
Group by continent
order by TotalDeathCount Desc

--Global numbers & info

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
From PortfolioProject..Covid_Deaths
Where continent is not null
Group By date
order by 1,2

--Looking at Vaccinatio Vs Total Population Conutrywise

Select *
From PortfolioProject..Covid_Deaths as CD
Join PortfolioProject..Covid_Vaccination as CV
     ON CD.location = CV.location
	 and CD.date= CV.date

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT (Int, CV.new_vaccinations)) OVER (Partition by CD.location Order by CD.location, CD.date) as TotalPeopleVaccinated

From PortfolioProject..Covid_Deaths as CD
Join PortfolioProject..Covid_Vaccination as CV
     ON CD.location = CV.location
	 and CD.date= CV.date
Where CD.continent is not null
Order by 2,3

--USE CTE(Comman Table Expression)

with PopulationVSVaccination (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)

as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT (Int, CV.new_vaccinations)) OVER (Partition by CD.location Order by CD.location, CD.date) as TotalPeopleVaccinated

From PortfolioProject..Covid_Deaths as CD
Join PortfolioProject..Covid_Vaccination as CV
     ON CD.location = CV.location
	 and CD.date= CV.date
Where CD.continent is not null
)
select *, (TotalPeopleVaccinated/population)*100 as Vaccination_Percent
From PopulationVSVaccination


--Using Temp Table
Drop Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT (Int, CV.new_vaccinations)) OVER (Partition by CD.location Order by CD.location, CD.date) as TotalPeopleVaccinated

From PortfolioProject..Covid_Deaths as CD
Join PortfolioProject..Covid_Vaccination as CV
     ON CD.location = CV.location
	 and CD.date= CV.date
Where CD.continent is not null
--Order by 2,3

Select *, (TotalPeopleVaccinated/population)*100 as Vaccination_Percent
From #PercentPeopleVaccinated


--Creating view for visualization

Create View PercentPeopleVaccinated as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT (Int, CV.new_vaccinations)) OVER (Partition by CD.location Order by CD.location, CD.date) as TotalPeopleVaccinated

From PortfolioProject..Covid_Deaths as CD
Join PortfolioProject..Covid_Vaccination as CV
     ON CD.location = CV.location
	 and CD.date= CV.date
Where CD.continent is not null

Select  *
From PercentPeopleVaccinated