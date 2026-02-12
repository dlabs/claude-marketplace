# Architecture Patterns Catalog

Reference catalog of common architectural patterns the architecture-strategist considers when designing solutions.

---

## Application Architecture Patterns

### Layered Architecture
- **When**: Standard CRUD applications, team familiarity
- **Layers**: Presentation → Application → Domain → Infrastructure
- **Trade-off**: Clear separation but can lead to anemic domain models

### Clean Architecture / Hexagonal
- **When**: Complex domain logic, need for testability
- **Key**: Dependencies point inward; domain has no external dependencies
- **Trade-off**: More boilerplate but highly testable and flexible

### CQRS (Command Query Responsibility Segregation)
- **When**: Read and write patterns differ significantly
- **Key**: Separate models for reads and writes
- **Trade-off**: Complexity increase but better optimization per path

### Event-Driven Architecture
- **When**: Decoupled services, async workflows, audit trails
- **Key**: Events as the communication mechanism
- **Trade-off**: Eventual consistency, harder debugging

### Microservices
- **When**: Independent team scaling, independent deployment needed
- **Key**: Service boundaries around business capabilities
- **Trade-off**: Network complexity, distributed transactions

### Modular Monolith
- **When**: Want microservice boundaries without network overhead
- **Key**: Module isolation within a single deployable
- **Trade-off**: Requires discipline to maintain boundaries

---

## Data Patterns

### Repository Pattern
- **When**: Abstract data access, multiple data sources
- **Common in**: Laravel (Eloquent), .NET, Java

### Unit of Work
- **When**: Coordinate multiple writes atomically
- **Common in**: Django, Entity Framework

### Active Record
- **When**: Simple CRUD, direct mapping to tables
- **Common in**: Rails, Laravel (Eloquent)

### Data Mapper
- **When**: Complex domain model different from DB schema
- **Common in**: Doctrine, Hibernate

### CQRS + Event Sourcing
- **When**: Full audit trail, complex state transitions
- **Note**: High complexity — only when genuinely needed

---

## API Patterns

### REST
- **When**: Standard CRUD, wide client compatibility
- **Key**: Resources, HTTP verbs, status codes
- **Convention**: `/api/v1/{resource}` with JSON:API or similar

### GraphQL
- **When**: Complex client data requirements, mobile apps
- **Key**: Client-driven queries, schema-first
- **Trade-off**: Caching complexity, authorization complexity

### gRPC
- **When**: Service-to-service, high performance
- **Key**: Protocol buffers, streaming support
- **Trade-off**: Not browser-native (needs proxy)

### tRPC
- **When**: TypeScript full-stack, type-safe API
- **Key**: Shared types between client and server
- **Trade-off**: TypeScript-only ecosystem

---

## Frontend Patterns

### Component-Based Architecture
- **When**: Always (modern frontend standard)
- **Key**: Reusable, composable UI components

### Container/Presenter (Smart/Dumb)
- **When**: Separating data fetching from rendering
- **Key**: Container handles logic, presenter handles UI

### Server Components (React/Next.js)
- **When**: Next.js App Router, data-heavy pages
- **Key**: Components render on server, stream to client
- **Trade-off**: New mental model, limited client interactivity

### Islands Architecture
- **When**: Mostly static content with interactive islands
- **Key**: Astro, partial hydration
- **Trade-off**: Limited for highly interactive apps

---

## State Management Patterns

### Centralized Store (Redux, Vuex)
- **When**: Complex shared state, time-travel debugging
- **Trade-off**: Boilerplate, indirection

### Atomic State (Jotai, Recoil)
- **When**: Fine-grained reactivity, derived state
- **Trade-off**: Can fragment state management

### Server State (TanStack Query, SWR)
- **When**: API data caching, optimistic updates
- **Key**: Treats server data differently from UI state

### Signal-Based (Solid, Angular Signals)
- **When**: Fine-grained reactivity without virtual DOM
- **Trade-off**: Different mental model

---

## Infrastructure Patterns

### Feature Flags
- **When**: Trunk-based development, gradual rollout, A/B testing
- **Key**: Decouple deployment from release

### Blue-Green Deployment
- **When**: Zero-downtime deployments
- **Key**: Two identical environments, traffic switching

### Canary Deployment
- **When**: Gradual rollout with monitoring
- **Key**: Route small % of traffic to new version

### Circuit Breaker
- **When**: Dependent services that may fail
- **Key**: Fail fast instead of waiting, auto-recover

### Saga Pattern
- **When**: Distributed transactions across services
- **Key**: Compensating transactions instead of ACID

---

## Anti-Patterns to Watch For

- **God Object/Class**: One class does everything
- **Distributed Monolith**: Microservices with tight coupling
- **Golden Hammer**: Using one technology for everything
- **Premature Optimization**: Optimizing before measuring
- **Big Ball of Mud**: No discernible architecture
- **Cargo Cult**: Copying patterns without understanding why
