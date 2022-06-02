--Query to get death percentage of covid cases in Us States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From Covid19.dbo.CovidDeaths
 order by 1,2




===================================================================
--Above is the query to get death percentage of covid cases in Us States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From Covid19.dbo.CovidDeaths
 Where locations like '%states%'
 order by 1,2




=======================================================================
-- Let's break things down by continent

 Select Location, Population , MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
 From Covid19.dbo.CovidDeaths
 Group by Location, Population
 Order by PopulationPercentageInfected desc



==========================================================================

-- Let's break things down by continent

 Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
 from Covid19.dbo.CovidDeaths
 where continent is not null
 group by location
 order by TotalDeathCount desc



=====================================================================


-- Let's break things down by continent
 (1) A
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	 from Covid19.dbo.CovidDeaths
	 where continent is not null
	 group by continent
	 order by TotalDeathCount desc


(2) B

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
	 from Covid19.dbo.CovidDeaths
	 where continent is null
	 group by location
	 order by TotalDeathCount desc



=======================================================================


--Combining or joining two data(excels) into 1

Select *
From Covid19.dbo.CovidDeaths dea
Join Covid19.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


==================================================================

--Then after combining or joining the 2 files above, now  will query TOTAL population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Covid19.dbo.CovidDeaths dea
Join Covid19.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

===================================================================
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid19..CovidDeaths dea
Join covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

=================================================

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid19..CovidDeaths dea
Join covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 