# MIT License

# Bondel Technologies S. A.

# Copyright (c) 2025, all rights reserved.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# For more information, contact https://github.com/marcosbondel

# · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
# · 

import asyncio
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import ORJSONResponse
from config.settings import settings
from config.database import init_mongo
from config.seed import seed_services
from config.worker import Worker
from routers import services
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Start Mongo Database
    # await init_mongo()

    # Execute seeds
    # await seed_services() #! Still have to ensure uniq records

    # Start workers
    Worker().perform()
    # asyncio.create_task(Worker().perform())

    yield


application = FastAPI(
    title=settings.app_name,
    lifespan=lifespan,
    default_response_class=ORJSONResponse
)

application.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*']
)

@application.get("/")
def root_application():
    return {
        "ok": True,
        "version": '1.0.0',
        "company": {
            "company_name": "Bondel Technologies S. A.",
            "description": "Building a better future",
            "github": "https://github.com/bondeltech"
        },
        "license": "MIT",
    }

# Routers
application.include_router(services.router)
