SERVICE := sample
STAGE := dev
CONTAINER := node:19-bullseye
NODE_CACHE_D := $(PWD)/node_modules
PORT := 3000
.DEFAULT_GOAL := local
local_ip := $$(ip route |grep kernel |awk 'END {print $$NF}')

tag:
	@tag="Release_${SERVICE}_$$(date +%Y%m%d.%H%M%S)" && git tag "$$tag" && echo "==> $$tag tagged."
zip:
	@zip -r ${SERVICE}.env.zip .env.development .env.production

clean_cache:
	sudo rm -rf $(NODE_CACHE_D)

# -e EXTERNAL_IP=$(local_ip)
# --add-host localhost:$(local_ip)
_node:
	@echo "==> Executing $(CMD)..." && \
		docker run -it --rm \
		-p $(PORT):$(PORT) \
		-w /src \
		--name node \
		-v $(PWD):/src \
		-v $(NODE_CACHE_D):/src/node_modules \
		$(CONTAINER) \
		$(CMD)

npmi:
	@make CMD='npm i' _node && make fix_perm
npmi-%:
	@make CMD='npm i ${*}' _node && make fix_perm

npmi_if_needed:
	@if [[ ! -e $(NODE_CACHE_D) ]]; then \
		make npmi; \
	fi

local: npmi_if_needed open_browser
	@make CMD='npm run dev' _node
open_browser:
	@command -v open >&/dev/null && \
		command -v ipa >&/dev/null && \
		open "http://$$(ipa):$(PORT)" &
attach: console
console:
	docker exec -it node /bin/bash --login

build: npmi_if_needed
	@if [[ $(STAGE) == "prd" ]]; then export OPT=-p; else export OPT=; fi && \
		echo "==> Building OPT=$${OPT}.." && \
		make CMD='/src/bin/build $${OPT}' _node
	@echo "==> Build Done"
	@make fix_perm

fix_perm:
	@if command -v mine >&/dev/null; then echo "=> Cleaning.." && mine -f $(NODE_CACHE_D) $(PWD)/dist/; fi
