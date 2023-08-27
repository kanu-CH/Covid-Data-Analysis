--COVID DEATHS TABLE

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

--data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

-- total cases vs total deaths (livelihood of dying if you contract covid in your country)

Select location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Death_percentage
From PortfolioProject..CovidDeaths
--Where location = 'India'
Where continent is not null
Order by 1,2

--total cases vs the population (percentage of population got covid)

Select location, date, total_cases, population, 
(CONVERT(float, total_cases) / population) * 100 AS Case_percentage
From PortfolioProject..CovidDeaths
--Where location = 'India'
Where continent is not null
Order by 1,2

--highest infection rate

Select location, population, MAX(total_cases) as Highest_Infection_Count,
MAX(CONVERT(float, total_cases) / population) * 100 AS Max_Case_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by Max_Case_Percentage desc

--highest death count per population

Select location, MAX(cast(total_deaths as int)) as Highest_Death_Count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by Highest_Death_Count desc

--highest death count on basis of continent

Select location, MAX(cast(total_deaths as int)) as Highest_Death_Count
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by Highest_Death_Count desc

-- continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as Highest_Death_Count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by Highest_Death_Count desc

--Global numbers

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ NULLIF(SUM(new_cases),0)*100 as Death_Percentage--, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- overall total case, total death and death percentage

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ NULLIF(SUM(new_cases),0)*100 as Death_Percentage--, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- COVID VACCINATIONS TABLE

Select *
From PortfolioProject..CovidVacinations
Order by 3, 4

--Joining both tables

Select *
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVacinations	vac
	on dae.location = vac.location 
	and dae.date = vac.date
Where dae.continent is not null

-- total population vs vaccination

Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVacinations	vac
	on dae.location = vac.location 
	and dae.date = vac.date
Where dae.continent is not null
Order by 1,2,3

-- total population vs toal no. of vaccination

Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dae.location order by dae.location, dae.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVacinations	vac
	on dae.location = vac.location 
	and dae.date = vac.date
Where dae.continent is not null
Order by 2,3

--using cte

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_People_Vaccinated)
as
(
Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dae.location order by dae.location, dae.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVacinations	vac
	on dae.location = vac.location 
	and dae.date = vac.date
Where dae.continent is not null
--Order by 2,3
)
SELECT * , (Rolling_People_Vaccinated/ Population)*100 as Vaccination_percentage
FROM PopvsVac

--temp table
 
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dae.location order by dae.location, dae.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVacinations	vac
	on dae.location = vac.location 
	and dae.date = vac.date
--Where dae.continent is not null
--Order by 2,3

SELECT * , (Rolling_People_Vaccinated/ Population)*100 as Vaccination_percentage
FROM #PercentPopulationVaccinated

-- creating view to store data for later

Create view PercentPopulationVaccinated as
Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dae.location order by dae.location, dae.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dae
Join PortfolioProject..CovidVacinations	vac
	on dae.location = vac.location 
	and dae.date = vac.date
--Where dae.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated