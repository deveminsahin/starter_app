# Incident Response Guide

Procedures for handling production incidents affecting the Starter App.

---

## Severity Levels

| Level | Impact | Response Time | Example |
|-------|--------|---------------|---------|
| **P1** | All users affected, core function broken | < 15 min | Login completely broken |
| **P2** | Many users affected, major feature broken | < 1 hour | Profile updates failing |
| **P3** | Some users affected, minor feature broken | < 4 hours | Settings page crash on specific device |
| **P4** | Minimal impact, cosmetic | Next business day | UI alignment issue |

---

## Incident Response Steps

### 1. Acknowledge

- Confirm the issue exists
- Assign severity level
- Notify stakeholders

### 2. Diagnose

- Check error monitoring (Sentry)
- Review recent deployments
- Check backend health
- Review logs

### 3. Mitigate

- Rollback if caused by recent deployment
- Apply hotfix if feasible
- Enable/disable feature flags
- Scale infrastructure if load-related

### 4. Communicate

- Update status page
- Notify affected users (if necessary)
- Internal updates to stakeholders

### 5. Resolve & Document

- Confirm fix is working
- Write post-mortem (for P1/P2)
- Update runbooks if new failure mode

---

## Common Issues & Solutions

### Authentication Failures

**Symptoms**: Users cannot log in, 401 errors

**Diagnosis**:
```dart
// Check token storage
final token = await tokenStorage.getAccessToken();
print('Token: ${token?.substring(0, 10)}...');
```

**Solutions**:
- Verify backend auth service is up
- Check token refresh logic
- Clear app data and retry

---

### Network Timeouts

**Symptoms**: Slow or failing API calls

**Diagnosis**:
- Check Dio interceptor logs
- Verify API endpoint reachability
- Check circuit breaker state

**Solutions**:
- Increase timeout values
- Check backend for slow queries
- Scale infrastructure

---

### App Crashes

**Symptoms**: App closes unexpectedly

**Diagnosis**:
- Check Crashlytics/Sentry for stack traces
- Review recent code changes
- Test on affected device/OS

**Solutions**:
- Deploy hotfix
- Rollback to stable version
- Disable problematic feature via feature flag

---

## Feature Flags for Mitigation

Quickly disable features without deployment:

```dart
// Check feature flag before risky operation
if (featureFlagService.isEnabled(FeatureFlag.newProfileFlow)) {
  // New code path
} else {
  // Safe fallback
}
```

---

## Escalation Contacts

| Role | Responsibility |
|------|----------------|
| On-call Engineer | First responder, diagnosis |
| Tech Lead | Decision authority |
| Product Manager | User communication |
| DevOps | Infrastructure issues |

---

## Post-Mortem Template

After P1/P2 incidents, document:

1. **Summary**: What happened?
2. **Timeline**: When did it start/end?
3. **Impact**: How many users affected?
4. **Root Cause**: Why did it happen?
5. **Resolution**: How was it fixed?
6. **Prevention**: How do we prevent recurrence?
